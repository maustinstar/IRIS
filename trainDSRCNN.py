import numpy
import keras
from keras.callbacks import ModelCheckpoint, Callback, TensorBoard
from keras.optimizers import SGD, Adam
import coremltools
from dsrcnn import model, save_model

def train(model, epochs):
	val_x = numpy.load("dataset/3_61.npy")[0][:800]
	val_y = numpy.load("dataset/6_61.npy")[0][:800]
	print val_x.shape
	# return
	for epoch in xrange(0, epochs):
		checkpointer = ModelCheckpoint(filepath="DSRCNN_" + str(epoch) + ".m5", monitor='val_loss', verbose=1, save_best_only=True)
		adam = Adam(lr=0.0003)
  		model.compile(optimizer=adam, loss='mean_squared_error', metrics=['mean_squared_error'])
		for i in xrange(7, 61, 2):
			print "Dataset: " + str(i)
			train_x = numpy.load("dataset/3_" + str(i) + ".npy")[0]
			train_x = numpy.concatenate([train_x, numpy.load("dataset/3_" + str(i + 1) + ".npy")[0]])
			train_y = numpy.load("dataset/6_" + str(i) + ".npy")[0]
			train_y = numpy.concatenate([train_y, numpy.load("dataset/6_" + str(i + 1) + ".npy")[0]])
			print train_x.shape

			hist = model.fit(train_x, train_y, validation_data=(val_x, val_y), shuffle=True, epochs = 2, batch_size=20, callbacks=[checkpointer], verbose=1, validation_steps=None)
			del train_x
			del train_y


if __name__ == '__main__':
	DSRCNN = model()
	train(DSRCNN, 15)