from PyQt6.QtWidgets import (
	QMainWindow,
	QApplication,
	QHBoxLayout,
	QVBoxLayout,
	QStackedLayout,
	QPushButton,
	QLineEdit,
	QWidget,
	QLabel,
	QComboBox
)
from PyQt6.QtGui import (
	QAction, QIcon
)
from PyQt6 import QtCore, QtWidgets

import sys
import os
import matplotlib
import numpy as np
import matplotlib.pyplot as plt

from model_class import InfectionModelExperimental
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg, NavigationToolbar2QT as NavigationToolBar
from matplotlib.figure import Figure

matplotlib.use('QtAgg')
matplotlib.pyplot.style.use('ggplot')


class MplCanvas(FigureCanvasQTAgg):
	def __init__(self, parent=None, width=5, height=4, dpi=100):
		self.fig, self.axes = plt.subplots(1, 2, figsize=(5, 4))
		super(MplCanvas, self).__init__(self.fig)


class GraphWindow(QMainWindow):
	def __init__(self, title):
		super().__init__()
		self.title = title
		self.initUI()

	def initUI(self):
		self.setWindowTitle(self.title)
		self.resize(1256, 512)
		self.graph = MplCanvas(self, width=20, height=10, dpi=100)
		main_layout = QVBoxLayout()
		graph_layout = QHBoxLayout()
		graph_layout.addWidget(self.graph)
		toolbar = NavigationToolBar(self.graph, self)
		main_layout.addWidget(toolbar)
		main_layout.addLayout(graph_layout)

		widget = QWidget()
		widget.setLayout(main_layout)
		self.setCentralWidget(widget)


class MainWindow(QMainWindow):
	def __init__(self):
		super().__init__()
		self.model = None
		self.setWindowTitle('Population builder')

		page_layout = QHBoxLayout()
		buttons_layout = QHBoxLayout()
		fields_layout = QVBoxLayout()
		# image_layout = QHBoxLayout()

		self.agents_type_label = QLabel(text='Agents type(rural or urban):')
		# self.agents_type_enter_qline = QLineEdit()
		self.agents_type_enter_qline = QComboBox(self)
		self.agents_type_enter_qline.addItems(['rural', 'urban'])
		self.hhs_count_label = QLabel(text='Household count:')
		self.hhs_count_enter_qline = QLineEdit()
		self.partner_age_dispersion_label = QLabel(text='Partners age difference dispersion:')
		self.partner_age_dispersion_qline = QLineEdit()
		start_building_btn = QPushButton('Start population building process')
		start_building_btn.clicked.connect(self.start_population_building)
		set_default_btn = QPushButton('Set default values')
		set_default_btn.clicked.connect(self.set_default_values)

		buttons_layout.addWidget(start_building_btn)
		buttons_layout.addWidget(set_default_btn)

		self.population_hist_graph = MplCanvas(self, width=20, height=10, dpi=100)
		self.contacts_heatmap_graph = MplCanvas(self, width=20, height=10, dpi=100)
		# image_layout.addWidget(self.population_hist_graph)
		# image_layout.addWidget(self.contacts_heatmap_graph)

		fields_layout.addWidget(self.agents_type_label)
		fields_layout.addWidget(self.agents_type_enter_qline)
		fields_layout.addWidget(self.hhs_count_label)
		fields_layout.addWidget(self.hhs_count_enter_qline)
		fields_layout.addWidget(self.partner_age_dispersion_label)
		fields_layout.addWidget(self.partner_age_dispersion_qline)
		fields_layout.addLayout(buttons_layout)

		page_layout.addLayout(fields_layout)
		# page_layout.addLayout(image_layout)

		widget = QWidget()
		widget.setLayout(page_layout)
		self.setCentralWidget(widget)

	def set_default_values(self):
		self.hhs_count_enter_qline.setText('329000')
		self.partner_age_dispersion_qline.setText('5')

	def start_population_building(self):
		agents_type = self.agents_type_enter_qline.currentText()
		hhs_count = int(self.hhs_count_enter_qline.text())
		partner_age_dispersion_qline = int(self.partner_age_dispersion_qline.text())
		self.model = InfectionModelExperimental(agents_type=agents_type, hhs_count=hhs_count,
												partner_age_dispersion=partner_age_dispersion_qline)
		self.model.load_process_data()

		axes = self.show_graph_window()
		self.model.draw_population_histogram(ax=axes[0])
		self.model.draw_contact_heatmap(ax=axes[1])

	def show_graph_window(self):
		self.graphWin = GraphWindow('Graph')
		self.graphWin.show()
		return self.graphWin.graph.axes


app = QApplication(sys.argv)
window = MainWindow()
window.resize(512, 256)
window.show()

app.exec()
