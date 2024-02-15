from flask import Flask
from flask import request

app = Flask(__name__)

@app.route('/upload/', methods=['GET', 'POST'])
def hello():
	if request.method == 'POST':
		#filename = request.form.get('upload_file_name')
		#return '''Successfully uploaded File "{}"'''.format(filename)
		f = open("/rshared/log.txt", "w")
		f.write(request.get_data(as_text=True, parse_form_data=True))
		f.close()
		return '''incoming request: {}'''.format(request.get_data(as_text=True, parse_form_data=True))

if __name__ == '__main__':
	app.run(debug=True, host='0.0.0.0')
