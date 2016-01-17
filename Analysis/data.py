import matplotlib.pyplot as plt
import pandas as pd
import numpy as np
import math
import datetime

def getDataFromFile(filename,personName):
	data = []
	with open(filename,'r') as f:
		for line in f:
			if line.startswith('Received:') and personName in line:
				content = line.split(',')
				data += [(float(content[1]),float(content[2]),float(content[3]),float(content[4]))]
	return data

def computeModulo(inputData, window=1):
	data=[]
	time=[]
	oldValue = [0,0,0];
	initialTime = float(inputData[0][0])
	step = 0
	total = 0
	for line in inputData:
		modulus = abs(line[1]-oldValue[0])+abs(line[2]-oldValue[1])+abs(line[3]-oldValue[2])
		oldValue[0]=line[1]
		oldValue[1]=line[2]
		oldValue[2]=line[3]
		step += 1
		total += modulus
		if ( step >= window ):
			data += [total]
			time += [datetime.datetime.fromtimestamp((line[0]-initialTime)/1000.0)]
			step = 0
			total = 0
		
			
	return (time,data)

inputData = getDataFromFile('../../Desktop/gunicorn.log','ettore')
(time,data) = computeModulo(inputData,1)
ts = pd.Series(data=data,index=time)
ts = pd.rolling_window(ts, window=1000, win_type='triang')
ts.plot(style='c-')
#ts = ts.interpolate(method='time')
plt.show()

