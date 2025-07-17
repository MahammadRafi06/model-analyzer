#!/bin/bash
set -ex


mkdir -p inception_onnx/1
wget -O /tmp/inception_v3_2016_08_28_frozen.pb.tar.gz \
     https://storage.googleapis.com/download.tensorflow.org/models/inception_v3_2016_08_28_frozen.pb.tar.gz
(cd /tmp && tar xzf inception_v3_2016_08_28_frozen.pb.tar.gz)
python3 -m venv tf2onnx
source ./tf2onnx/bin/activate
pip3 install "numpy<2" tensorflow tf2onnx
python3 -m tf2onnx.convert --graphdef /tmp/inception_v3_2016_08_28_frozen.pb --output inception_v3_onnx.model.onnx --inputs input:0 --outputs InceptionV3/Predictions/Softmax:0
deactivate
mv inception_v3_onnx.model.onnx inception_onnx/1/model.onnx


# ONNX densenet
mkdir -p densenet_onnx/1
wget -O densenet_onnx/1/model.onnx \
     https://github.com/onnx/models/raw/main/validated/vision/classification/densenet-121/model/densenet-7.onnx
