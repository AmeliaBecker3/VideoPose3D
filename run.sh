#! /bin/bash
# Run this file in the parent directory

if [ $# -eq 0 ]; then
    echo "Usage: $0 input_video.mp4"
    exit 1
fi

home=`pwd`
cd VideoPose3D
d=`pwd`
videoname=`basename $1`
dirname=`dirname $1`
shortname="${videoname%.*}"
cp ../$1 input_directory
python3 inference/infer_video_d2.py \
    --cfg COCO-Keypoints/keypoint_rcnn_R_101_FPN_3x.yaml \
    --output-dir output_directory \
    --image-ext mp4 \
    input_directory/
cd data
python3 prepare_data_2d_custom.py -i ../output_directory -o processed
cd $d
python3 run.py -d custom -k processed -arc 3,3,3,3,3 \
	-c checkpoint --evaluate pretrained_h36m_detectron_coco.bin \
	--render --viz-subject $videoname --viz-action custom --viz-camera 0 \
	--viz-export output_directory/$videoname-positions.npz
python3 npy2csv-3d.py output_directory/$videoname-positions.npz.npy
rm input_directory/$videoname
cd $home
cd open-body-fit-devel/bin
./open-body-fit \
	-i ../data/Amelia/skeleton.ini --no-win \
	../../VideoPose3D/output_directory/$shortname.csv
./compute-metrics --no-win \
	../../VideoPose3D/output_directory/$shortname.bvh
cd $home
mkdir -p $dirname/$shortname
mv -f VideoPose3D/output_directory/$shortname* $dirname/$shortname
mv -f VideoPose3D/output_directory/$videoname* $dirname/$shortname
