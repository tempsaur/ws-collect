import pyperclip

first = 'HeadLabel'

thing = '''
<MyObject Name="Thing{}" Type="Label" Assembly="BaseControls">
	<Top>
	<Formula>
		<Plus DataType="IntegerDataType">
		<Item>
			<Object Name="{}">
			<Property Name="Bottom" />
			</Object>
		</Item>
		<Item>{}</Item>
		</Plus>
	</Formula>
	</Top>
	<Left>10</Left>
	<Width>400</Width>
	<Text>{}</Text>
</MyObject>
'''

stuffs = [
    'Таблица: Дата запроса ЕГПУ, дата постановления на ЗП',
    'Табпорт: ID долга',
    'Таблица: последний комментарий',
    'Таблица: самый поздний контрольный срок',
    'Таблица: взыскание, контрольный срок взыскания',
    'Контрольный срок для учета взаимодействия',
    'Комментарии и взаимодействи привязаны к человеку',
    'Экспорт: Номер судебного дела',
    'Экспорт: Суд взыскания, статусы',
    'Таблица: Последний запрос ЕГПУ',
    'Это окошко',
    'Сужение расширение главного окна',
    'Таблица: Название судов',
]

xml = ''

for i, text in enumerate(stuffs):
	bottom = f'Thing{i}' if i != 0 else first
	padding = 2 if i != 0 else 25

	xml += thing.format(i + 1, bottom, padding, text) + '\n'
pyperclip.copy(xml)
