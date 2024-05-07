import matplotlib.pyplot as plt



colors = ['blue', 'cyan', 'red', 'pink', 'green']

processes = {
    1: [1445, 1446, 1464, 1532],
    2: [1445, 1449, 1466, 1535],
    3: [1445, 1447, 1470, 1538],
    4: [1445, 1450, 1468, 1541],
    5: [1445, 1448, 1472, 1544]
}

for process, timeline in processes.items():
    timelen = len(timeline)
    i=0
    while i<timelen-1:
        
        start_time = timeline[i]
        end_time = timeline[i + 1]
        plt.hlines(y=i + 1, xmin=start_time, xmax=end_time, color=colors[process - 1], linewidth=3)
        plt.vlines(x=end_time, ymin=i + 1, ymax=i + 2, color=colors[process - 1], linewidth=2)
        i+=1
    end_of_graph=0
    for k in processes.values():
        if k[-1]>end_of_graph:
            end_of_graph=k[-1]

    plt.hlines(y=len(timeline), xmin=timeline[-1], xmax=end_of_graph, color=colors[process - 1], linewidth=0.5)
      


legend_labels = [f'Process {i}' for i in range(1, len(processes) + 1)]
handles = [plt.Line2D([0], [0], color=colors[i], label=legend_labels[i]) for i in range(len(processes))]
plt.legend(handles=handles)

plt.xlabel('Time in Ticks')
plt.ylabel('Queue')
plt.title('Process Lifetimes')

plt.yticks([1, 2, 3, 4, 5])

plt.grid(axis='x')
plt.show()
