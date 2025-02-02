#!/usr/bin/env bash

set -exu

output_dir=${1:-"exp_out"}
run_id=${2:-1}

dataset_file=$GRINCH_ROOT/data/aloi.tsv
dataset_name=aloi

num_runs=1
num_threads=4
par_max_frontier=50

TIME=`(date +%Y-%m-%d-%H-%M-%S-%3N)`

output_dir="${output_dir}/$TIME"

mkdir -p $output_dir

# Shuffle
#sh bin/util/shuffle_dataset.sh $dataset_file $num_runs

expected_dp_point_file="None"

for i in `seq $run_id  $run_id`
    do
        algorithm_name="GrinchCosLink"
        shuffled_data="${dataset_file}.$i"
        exp_output_dir="$output_dir/$dataset_name/$algorithm_name/run_$i"

        java -Xmx20G -cp $GRINCH_JARPATH grinch.eval.RunGrinch \
        --input $shuffled_data \
        --outdir $exp_output_dir \
        --algorithm $algorithm_name \
        --dataset $dataset_name \
        --max-leaves None \
        --clusters None \
        --threads $num_threads \
        --max-frontier-par $par_max_frontier \
        --k 50 \
        --max_num_leaves=-1 \
        --graft_beam 100000000 \
        --rotation_size_cap 100 \
        --graft_size_cap 100 \
        --restruct_size_cap 100 \
        --perform_rotate true \
        --perform_graft true \
        --perform_restruct true \
        --single_graft_search true \
        --single_elimination true \
        --nsw_r 3 \
        --exact_nn false \
        --max_degree 500 \
        --linkage coslink

        sh bin/util/score_tree.sh \
        $exp_output_dir/tree.tsv $algorithm_name $dataset_name $num_threads $expected_dp_point_file \
         > $exp_output_dir/score.txt

        cat $exp_output_dir/score.txt
done
