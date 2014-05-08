import csv
import matplotlib.pyplot as plt

#Compares Simulation cost to VIA cost

infile = open('./out/AllComp.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

Simmhistdata = [eval(data[e][-3]) - eval(data[e][-2]) for e in range(1,len(data))]
Simmhistdata += [eval(data[e][-6]) - eval(data[e][-5]) for e in range(1,len(data))]
Simmhistdata += [eval(data[e][-9]) - eval(data[e][-8]) for e in range(1,len(data))]


#Evaluates the performence of the heuristics

infile = open('./out/AllComp.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

IndepComp = [eval(data[e][-3]) / eval(data[e][-9]) for e in range(1,len(data))]
N2approxComp = [eval(data[e][-3]) / eval(data[e][-6]) for e in range(1,len(data))]

plt.hist(IndepComp,bins = 20,label = 'Independant')
plt.hist(N2approxComp,histtype = 'stepfilled',bins = 20,color = 'r',alpha = 0.5,label = 'N2Approx')
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('mean indep = %.2f mean N2 approx = %.2f' %( sum(IndepComp)/len(IndepComp) , sum(N2approxComp)/len(N2approxComp)) )
plt.legend(loc = 'upper left')
plt.show()
plt.savefig('./out/HeuristicComp.png')
plt.clf()
plt.close()

plt.hist(Simmhistdata,bins = 20)
plt.title('mean = %.2f' %( sum(Simmhistdata)/len(Simmhistdata) ) )
plt.savefig('./out/Validation.pdf')
plt.clf()
plt.close()

#Demand experiments

files = [f for f in os.listdir('./out/') if os.path.isfile(os.path.join('out/',f))]
files = [f for f in files if 'Lambda' in f and '.csv' in f ]
files = [f for f in files if not 'pdf' in f ]

for f in files:
    infile = open('./out/' + f,'rb')
    data = csv.reader(infile)
    data = [row for row in data]
    infile.close()
    plotdata = []
    plotdatasim = []
    plotdataIndep = []
    plotdataIndepsim = []

    for row in data:
        plotdata.append([eval(row[0]),eval(row[-3])])
        plotdatasim.append([eval(row[0]),eval(row[-2])])
        plotdataIndep.append([eval(row[0]),eval(row[-6])])
        plotdataIndepsim.append([eval(row[0]),eval(row[-5])])
    p = list_plot(plotdata,plotjoined = True, color = 'red',legend_label = 'VIA')
    p += list_plot(plotdatasim,plotjoined = True,color = 'blue',legend_label = 'Simm',axes_labels = ['$\lambda$','Cost'],title = 'Lambda Experiment')
    p.save('out/%s.pdf' %f[:-4])
    p = list_plot(plotdataIndep,plotjoined = True, color = 'red',legend_label = 'Indep')
    p += list_plot(plotdata,plotjoined = True,color = 'blue',legend_label = 'VIA',axes_labels = ['$\lambda$','Cost'],title = 'Lambda Experiment')
    p.save('out/Indep%s.pdf' %f[:-4])




infile = open('./out/L4L.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

plotdataKT = [eval(row[-5])/eval(row[-11]) for row in data]
plotdatan2 = [eval(row[-3])/eval(row[-11]) for row in data]


plt.hist(plotdataKT,bins = 20,label = ['KT'])
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('Approx. KT mean = %.2f Prop wins = %.2f' %( sum(plotdataKT)/len(plotdataKT), float(len([ i for i in plotdataKT if i <= 1]))/len(plotdataKT) ) )
plt.savefig('./out/KTL4L.pdf')
plt.clf()
plt.close()

plt.hist(plotdatan2,bins = 20,label = ['N2'])
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('Aprox N2 mean = %.2f Prop wins = %.2f' %( sum(plotdatan2)/len(plotdatan2), float(len([ i for i in plotdatan2 if i <= 1]))/len(plotdatan2) ) )
plt.savefig('./out/N2L4L.pdf')
plt.clf()
plt.close()



plt.hist(plotdataKT,bins = 20,label = 'KT')
plt.hist(plotdatan2,bins = 20,alpha = 0.5,color = 'r',label = 'N2')
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.legend()
plt.title('Approx. KT and N2' )
plt.savefig('./out/L4L.png')
plt.clf()
plt.close()

infile = open('./out/HiS2.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

SimmComp = [eval(data[e][-3]) / eval(data[e][-12]) for e in range(len(data))]
SimmComp = [e for e in SimmComp if not e ==1]
SimmComp2 = [eval(data[e][-6]) / eval(data[e][-12]) for e in range(len(data))]
SimmComp2 = [e for e in SimmComp2 if not e ==1]
plt.hist(SimmComp,bins = 100,label = 'N2')
plt.hist(SimmComp2,bins = 100,alpha = 0.5,color = 'r',label = 'KT')
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('SimmMethods Comp mean = %.2f Prop wins = %s' %( sum(SimmComp)/len(SimmComp), float(len([ i for i in SimmComp if i <= 1]))/len(SimmComp) ) )
plt.savefig('./out/HighS2.png')
plt.clf()
plt.close()

infile = open('./out/HiS1.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

SimmComp = [eval(data[e][-6]) / eval(data[e][-12]) for e in range(len(data))]
plt.hist(SimmComp,bins = 100,label = ['Independant'])
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('Aprox N2 for high S1 mean = %.2f Prop wins = %s' %( sum(SimmComp)/len(SimmComp), float(len([ i for i in SimmComp if i <= 1]))/len(SimmComp) ) )
plt.savefig('./out/HighS1.pdf')
plt.clf()
plt.close()


infile = open('./out/Qinvestigation.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

SimmComp = [eval(data[e][-3]) / eval(data[e][-12]) for e in range(len(data))]
SimmComp = [e for e in SimmComp if not e ==1]
plt.hist(SimmComp,bins = 100,label = ['Independant'])
plt.xlabel('Cost Ratio')
plt.ylabel('Freq')
plt.title('Aprox N2 for Low Q mean = %.2f Prop wins = %s' %( sum(SimmComp)/len(SimmComp), float(len([ i for i in SimmComp if i <= 1]))/len(SimmComp) ) )
plt.savefig('./out/Q.pdf')
plt.clf()
plt.close()




infile = open('./out/Timings.csv','rb')
data = csv.reader(infile)
data = [row for row in data]
infile.close()

plot_dict = {}
plot_dictr = {}
for row in data:
    if row[0] in plot_dict:
        plot_dict[row[0]]['Indep'].append(eval(row[10]))
        plot_dict[row[0]]['N2Simm'].append(eval(row[22]))
        plot_dict[row[0]]['SimmKT'].append(eval(row[17]))
        plot_dict[row[0]]['VIA'].append(eval(row[14]))
#        plot_dict[row[0]]['Ana'].append(eval(row[26]))

        plot_dictr[row[0]]['Indep'].append(eval(row[8])/eval(row[12]))
        plot_dictr[row[0]]['N2Simm'].append(eval(row[20])/eval(row[12]))
        plot_dictr[row[0]]['SimmKT'].append(eval(row[16])/eval(row[12]))
        plot_dictr[row[0]]['VIA'].append(eval(row[12])/eval(row[12]))
 #       plot_dictr[row[0]]['Ana'].append(eval(row[24])/eval(row[12]))
    else:
        plot_dict[row[0]] = {}

        plot_dict[row[0]]['Indep'] = [eval(row[10])]
        plot_dict[row[0]]['N2Simm'] = [eval(row[22])]
        plot_dict[row[0]]['SimmKT'] = [eval(row[17])]
        plot_dict[row[0]]['VIA'] = [eval(row[14])]
  #      plot_dict[row[0]]['Ana'] = [eval(row[26])]

        plot_dictr[row[0]] = {}

        plot_dictr[row[0]]['Indep'] = [eval(row[8])/eval(row[12])]
        plot_dictr[row[0]]['N2Simm'] = [eval(row[20])/eval(row[12])]
        plot_dictr[row[0]]['SimmKT'] = [eval(row[16])/eval(row[12])]
        plot_dictr[row[0]]['VIA'] = [eval(row[12])/eval(row[12])]
   #     plot_dictr[row[0]]['Ana'] = [eval(row[24])/eval(row[12])]

ave_dict = {}
#for e in plot_dict:
#    ave_dict[e] = 1/max([sum(plot_dict[e]['VIA'])/len(plot_dict[e]['VIA']),sum(plot_dict[e]['N2Simm'])/len(plot_dict[e]['N2Simm']),sum(plot_dict[e]['SimmKT'])/len(plot_dict[e]['SimmKT']),sum(plot_dict[e]['Indep'])/len(plot_dict[e]['Indep']),sum(plot_dict[e]['Ana'])/len(plot_dict[e]['Ana'])])
plot_data_via = [[eval(e),sum(plot_dict[e]['VIA'])/len(plot_dict[e]['VIA'])] for e in plot_dict]
plot_data_Indep = [[eval(e),sum(plot_dict[e]['Indep'])/len(plot_dict[e]['Indep'])] for e in plot_dict]
plot_data_N2 = [[eval(e),sum(plot_dict[e]['N2Simm'])/len(plot_dict[e]['N2Simm'])] for e in plot_dict]
plot_data_KT = [[eval(e),sum(plot_dict[e]['SimmKT'])/len(plot_dict[e]['SimmKT'])] for e in plot_dict]
#plot_data_Ana = [[eval(e),sum(plot_dict[e]['Ana'])/len(plot_dict[e]['Ana'])] for e in plot_dict]

plot_data_via.sort()
plot_data_Indep.sort()
plot_data_N2.sort()
plot_data_KT.sort()
#plot_data_Ana.sort()

Q = list_plot(plot_data_via,plotjoined = True,color = 'blue',axes_labels = ['NxN Size State Space','t'],legend_label = 'Value Iteration',title = 'Time Taken to compute policy')
Q.save('./out/timingvia.pdf')
p = list_plot(plot_data_via,plotjoined = True,color = 'red',axes_labels = ['NxN Size State Space','t'],legend_label = 'Value Iteration',title = 'Time Taken to compute policy')
p += list_plot(plot_data_Indep,plotjoined = True,color = 'blue',legend_label = 'Independant')
p += list_plot(plot_data_N2,plotjoined = True,color = 'green',legend_label = 'Simmulating N2')
p += list_plot(plot_data_KT,plotjoined = True,color = 'yellow',legend_label = 'Simmulating KT')
p += list_plot(plot_data_Ana,plotjoined = True,color = 'black',legend_label = 'Analytical')

p.save('./out/timingall.pdf')

plot_data_via = [[eval(e),ave_dict[e]*(sum(plot_dictr[e]['VIA'])/len(plot_dictr[e]['VIA']))*(sum(plot_dict[e]['VIA'])/len(plot_dict[e]['VIA']))] for e in plot_dict]
plot_data_Indep = [[eval(e),ave_dict[e]*(sum(plot_dictr[e]['Indep'])/len(plot_dictr[e]['Indep']))*sum(plot_dict[e]['Indep'])/len(plot_dict[e]['Indep'])] for e in plot_dict]
plot_data_N2 = [[eval(e),ave_dict[e]*(sum(plot_dictr[e]['N2Simm'])/len(plot_dictr[e]['N2Simm']))*sum(plot_dict[e]['N2Simm'])/len(plot_dict[e]['N2Simm'])] for e in plot_dict]
plot_data_KT = [[eval(e),ave_dict[e]*(sum(plot_dictr[e]['SimmKT'])/len(plot_dictr[e]['SimmKT']))*sum(plot_dict[e]['SimmKT'])/len(plot_dict[e]['SimmKT'])] for e in plot_dict]
plot_data_Ana = [[eval(e),ave_dict[e]*(sum(plot_dictr[e]['Ana'])/len(plot_dictr[e]['Ana']))*sum(plot_dict[e]['Ana'])/len(plot_dict[e]['Ana'])] for e in plot_dict]

plot_data_via.sort()
plot_data_Indep.sort()
plot_data_N2.sort()
plot_data_KT.sort()
plot_data_Ana.sort()

p = list_plot(plot_data_via,plotjoined = True,color = 'red',axes_labels = ['NxN Size State Space','$ r t $'],legend_label = 'Value Iteration',title = 'Weighted Time Taken to compute policy')
p += list_plot(plot_data_Indep,plotjoined = True,color = 'blue',legend_label = 'Independant')
p += list_plot(plot_data_N2,plotjoined = True,color = 'green',legend_label = 'Simmulating N2')
p += list_plot(plot_data_KT,plotjoined = True,color = 'yellow',legend_label = 'Simmulating KT')
p += list_plot(plot_data_Ana,plotjoined = True,color = 'black',legend_label = 'Analytical')

p.save('./out/timingweightedall.pdf')

files = [f for f in os.listdir('./out/poa/') if os.path.isfile(os.path.join('out/poa/',f))]
files = [f for f in files if 'poa' in f and '.csv' in f ]
files = [f for f in files if not 'pdf' in f ]

for f in files:
    infile = open('./out/poa/' + f,'rb')
    data = csv.reader(infile)
    data = [row for row in data]
    infile.close()
    plotdata = []

    for row in data:
        plotdata.append([eval(row[0]),eval(row[-3])/eval(row[-5])])
    print plotdata
    p = list_plot(plotdata,plotjoined = True, color = 'red',legend_label = 'PoA',axes_labels = ['$\lambda$','Cost'],title = 'PoA Experiment')
    p.save('out/poa/%s.pdf' %f[:-4])
