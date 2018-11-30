import keras
print keras.__version__
import sys
from keras.layers import Conv2D, Input, BatchNormalization, UpSampling2D, Deconvolution2D, Conv2DTranspose, Activation, add
from keras.callbacks import ModelCheckpoint, Callback, TensorBoard
from keras.optimizers import SGD, Adam
from keras.models import Model
import numpy
import coremltools
print keras.__version__

def model():
  inputLayer = Input(shape=(256, 256, 3))
  DSRCNN = UpSampling2D(size=2)(inputLayer)
  inputImage = DSRCNN
  DSRCNN = Conv2D(9, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(16, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(32, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(64, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(64, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(64, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(32, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(16, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(9, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("relu")(DSRCNN)
  DSRCNN = Conv2D(3, (3, 3), strides=(1, 1), padding="same", init='glorot_uniform')(DSRCNN)
  DSRCNN = Activation("linear")(DSRCNN)
  residualImage = DSRCNN
  outputImage = add([inputImage, residualImage])

  DSRCNN = Model(inputLayer, outputImage)
  print DSRCNN.summary()
  return DSRCNN


def save_model(model, name):
  coreml_model = coremltools.converters.keras.convert(model,
    input_names = 'image',
    image_input_names = 'image',
    image_scale = 0.00392156863)

  coreml_model.save("./" + name + ".mlmodel")








