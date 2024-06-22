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
    'Комментарии и взаимодействи привязаны к человеку',
    'Экспорт: Номер судебного дела',
    'Экспорт: Суд взыскания, статусы',
    'Таблица: Последний запрос ЕГПУ',
    'Это окошко',
    'Сужение расширение главного окна',
    'Таблица: Название судов',
]

for i, text in enumerate(stuffs):
	bottom = f'Thing{i}' if i != 0 else first
	padding = 2 if i != 0 else 25

	print(thing.format(i + 1, bottom, padding, text))
