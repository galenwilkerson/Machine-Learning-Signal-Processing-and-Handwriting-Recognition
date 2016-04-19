import matplotlib.pyplot as plt
import numpy as np
column_labels = list('BACD')
row_labels = list('XWYZ')
data = np.random.rand(4,4)
fig, ax = plt.subplots()
#heatmap = ax.pcolor(data, cmap=plt.cm.Blues, label = 'heatmap')
heatmap = ax.pcolormesh(data, cmap=plt.cm.Greys)

# put the major ticks at the middle of each cell
ax.set_xticks(np.arange(data.shape[0])+0.5, minor=False)
ax.set_yticks(np.arange(data.shape[1])+0.5, minor=False)

# want a more natural, table-like display
ax.invert_yaxis()
#ax.xaxis.tick_top()

ax.set_xticklabels(row_labels, minor=False, rotation=45, size = 'small')
ax.set_yticklabels(column_labels, minor=False, size = 'small')
ax.set_title('heatmap', size = 'small')
plt.legend()    
fig.subplots_adjust(hspace=0.6, wspace=0.6)

fig.colorbar(heatmap)

plt.show()


# put in dataframe, sort by labels
import pandas as pd
d = pd.DataFrame(data, columns = column_labels)


