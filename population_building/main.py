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
	QComboBox,
	QMenuBar,
	QToolBar,
	QMenu
)
from PyQt6.QtGui import (
	QAction, QIcon
)
from PyQt6 import QtCore, QtWidgets
from PyQt6.QtCore import QSize

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


class SetDistributionParametersWindow(QMainWindow):
	def __init__(self):
		super().__init__()
		main_layout = QHBoxLayout()
		block1_layout = QVBoxLayout()
		block2_layout = QVBoxLayout()
		block3_layout = QVBoxLayout()

		# first block widgets
		self.hhs_data_enter_field_label = QLabel(text='Enter path to households data:')
		self.hhs_data_enter_field = QLineEdit()
		self.hhs_data_enter_field.setText('./data/bryansk_data.xlsx')

		self.people_age_sex_data_enter_field_label = QLabel(text='Enter path to age/sex data:')
		self.people_age_sex_data_enter_field = QLineEdit()
		self.people_age_sex_data_enter_field.setText('./data/Age_sex_count_v1.xlsx')

		self.men_marriage_urban_data_enter_field_label = QLabel(text='Enter path to men urban data:')
		self.men_marriage_urban_data_enter_field = QLineEdit()
		self.men_marriage_urban_data_enter_field.setText('./population_building_data/marriage_data/bryansk_urban_men_marriage_data.xlsx')

		self.men_marriage_rural_data_enter_field_label = QLabel(text='Enter path to men rural data:')
		self.men_marriage_rural_data_enter_field = QLineEdit()
		self.men_marriage_rural_data_enter_field.setText('./population_building_data/marriage_data/bryansk_rural_men_marriage_data.xlsx')

		block1_layout.addWidget(self.hhs_data_enter_field_label)
		block1_layout.addWidget(self.hhs_data_enter_field)
		block1_layout.addWidget(self.people_age_sex_data_enter_field_label)
		block1_layout.addWidget(self.people_age_sex_data_enter_field)
		block1_layout.addWidget(self.men_marriage_urban_data_enter_field_label)
		block1_layout.addWidget(self.men_marriage_urban_data_enter_field)
		block1_layout.addWidget(self.men_marriage_rural_data_enter_field_label)
		block1_layout.addWidget(self.men_marriage_rural_data_enter_field)

		# second block widgets
		self.pair1_data_enter_field_label = QLabel(text='Enter path to pair1 data:')
		self.pair1_data_enter_field = QLineEdit()
		self.pair1_data_enter_field.setText('population_building_data/pair1.xlsx')

		self.pair2_data_enter_field_label = QLabel(text='Enter path to pair2 data:')
		self.pair2_data_enter_field = QLineEdit()
		self.pair2_data_enter_field.setText('population_building_data/pair2.xlsx')

		self.pair3_data_enter_field_label = QLabel(text='Enter path to pair3 data:')
		self.pair3_data_enter_field = QLineEdit()
		self.pair3_data_enter_field.setText('population_building_data/pair3.xlsx')

		self.pair_summary_data_enter_field_label = QLabel(text='Enter path ot pair data summary:')
		self.pair_summary_data_enter_field = QLineEdit()
		self.pair_summary_data_enter_field.setText('population_building_data/summary.xlsx')

		block2_layout.addWidget(self.pair1_data_enter_field_label)
		block2_layout.addWidget(self.pair1_data_enter_field)
		block2_layout.addWidget(self.pair2_data_enter_field_label)
		block2_layout.addWidget(self.pair2_data_enter_field)
		block2_layout.addWidget(self.pair3_data_enter_field_label)
		block2_layout.addWidget(self.pair3_data_enter_field)
		block2_layout.addWidget(self.pair_summary_data_enter_field_label)
		block2_layout.addWidget(self.pair_summary_data_enter_field)

		# third block widgets
		self.pair1_with_childs_enter_field_label = QLabel(text='Enter path to pair1 childs data:')
		self.pair1_with_childs_enter_field = QLineEdit()
		self.pair1_with_childs_enter_field.setText('population_building_data/pair1_v2.xlsx')

		self.pair2_with_childs_enter_field_label = QLabel(text='Enter path to pair2 childs data:')
		self.pair2_with_childs_enter_field = QLineEdit()
		self.pair2_with_childs_enter_field.setText('population_building_data/pair2_v2.xlsx')

		self.pair3_with_childs_enter_field_label = QLabel(text='Enter path to pair3 childs data:')
		self.pair3_with_childs_enter_field = QLineEdit()
		self.pair3_with_childs_enter_field.setText('population_building_data/pair3_v2.xlsx')

		self.mother_age_distribution_enter_field_label = QLabel(text='Enter path to mothers age data:')
		self.mother_age_distribution_enter_field = QLineEdit()
		self.mother_age_distribution_enter_field.setText('./data/mothers_data/BRaO2015-2021.txt')

		block3_layout.addWidget(self.pair1_with_childs_enter_field_label)
		block3_layout.addWidget(self.pair1_with_childs_enter_field)
		block3_layout.addWidget(self.pair2_with_childs_enter_field_label)
		block3_layout.addWidget(self.pair2_with_childs_enter_field)
		block3_layout.addWidget(self.pair3_with_childs_enter_field_label)
		block3_layout.addWidget(self.pair3_with_childs_enter_field)
		block3_layout.addWidget(self.mother_age_distribution_enter_field_label)
		block3_layout.addWidget(self.mother_age_distribution_enter_field)

		main_layout.addLayout(block1_layout)
		main_layout.addLayout(block2_layout)
		main_layout.addLayout(block3_layout)

		widget = QWidget()
		widget.setLayout(main_layout)
		self.setCentralWidget(widget)
		self.resize(1256, 364)

		# Adding 'apply' action
		self.apply_action = QAction("Apply", self)
		toolbar = self.addToolBar("Apply params")
		toolbar.setMovable(False)
		toolbar.addAction(self.apply_action)


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
		self.mothers_age_distribution_data_path = None
		self.pair3_childs_data_path = None
		self.pair2_childs_data_path = None
		self.pair1_childs_data_path = None
		self.pair_summary_data_path = None
		self.pair3_data_path = None
		self.pair2_data_path = None
		self.pair1_data_path = None
		self.men_marriage_urban_data_path = None
		self.men_marriage_rural_data_path = None
		self.peoples_age_sex_data_path = None
		self.households_data_path = None
		self.model = None
		self.setWindowTitle('Population builder')

		page_layout = QHBoxLayout()
		buttons_layout = QHBoxLayout()
		fields_layout = QVBoxLayout()
		# image_layout = QHBoxLayout()

		# main parameters enter field
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

		# create set parameters option
		set_sources_action = QAction('Set Distribution Parameters', self)
		set_sources_action.triggered.connect(self.open_set_sources_window)


		# add toolbar
		toolbar = self.addToolBar('Set Distribution Params')
		toolbar.setMovable(False)
		toolbar.addAction(set_sources_action)


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
		if self.households_data_path is not None:
			self.model.households_data_path = self.households_data_path
			self.model.peoples_age_sex_data_path = self.peoples_age_sex_data_path
			self.model.men_marriage_urban_data_path = self.men_marriage_urban_data_path
			self.model.men_marriage_urban_data_path = self.men_marriage_urban_data_path
			self.model.pair1_data_path = self.pair1_data_path
			self.model.pair2_data_path = self.pair2_data_path
			self.model.pair3_data_path = self.pair3_data_path
			self.model.pair_summary_data_path = self.pair_summary_data_path
			self.model.pair1_childs_data_path = self.pair1_childs_data_path
			self.model.pair2_childs_data_path = self.pair2_childs_data_path
			self.model.pair3_childs_data_path = self.pair3_childs_data_path
			self.model.mothers_age_distribution_data_path = self.mothers_age_distribution_data_path

		self.model.load_process_data()

		axes = self.show_graph_window()
		self.model.draw_population_histogram(ax=axes[0])
		self.model.draw_contact_heatmap(ax=axes[1])

	def show_graph_window(self):
		self.graphWin = GraphWindow('Graph')
		self.graphWin.show()
		return self.graphWin.graph.axes

	def open_set_sources_window(self):
		self.SetParamsWindow = SetDistributionParametersWindow()
		self.SetParamsWindow.apply_action.triggered.connect(self.distribution_params_action_handler)
		self.SetParamsWindow.show()

	def distribution_params_action_handler(self):
		self.households_data_path = self.SetParamsWindow.hhs_data_enter_field.text()
		self.peoples_age_sex_data_path = self.SetParamsWindow.people_age_sex_data_enter_field.text()
		self.men_marriage_urban_data_path = self.SetParamsWindow.men_marriage_urban_data_enter_field.text()
		self.men_marriage_urban_data_path = self.SetParamsWindow.men_marriage_rural_data_enter_field.text()
		self.pair1_data_path = self.SetParamsWindow.pair1_data_enter_field.text()
		self.pair2_data_path = self.SetParamsWindow.pair2_data_enter_field.text()
		self.pair3_data_path = self.SetParamsWindow.pair3_data_enter_field.text()
		self.pair_summary_data_path = self.SetParamsWindow.pair_summary_data_enter_field.text()
		self.pair1_childs_data_path = self.SetParamsWindow.pair1_with_childs_enter_field.text()
		self.pair2_childs_data_path = self.SetParamsWindow.pair2_with_childs_enter_field.text()
		self.pair3_childs_data_path = self.SetParamsWindow.pair3_with_childs_enter_field.text()
		self.mothers_age_distribution_data_path = self.SetParamsWindow.mother_age_distribution_enter_field.text()
		print('Parameters applied successfully')



app = QApplication(sys.argv)
window = MainWindow()
window.setFixedSize(512, 256)
window.show()

app.exec()
