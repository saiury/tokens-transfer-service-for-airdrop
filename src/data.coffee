fs = require('fs').promises
axios = require('axios')
keys = require '../keys.js'

ADDR = 'http://api.etherscan.io/api'


log = console.log

delay = (ms)->
	return new Promise (resolve, reject)=>
		setTimeout resolve, ms


read = (file_name, res_file_name)->
	res = await fs.readFile file_name
	res = String res
	arr = res.split '\n'

	id = 3000
	res = ''
	summ = 0
	for val in arr
		tmp = val.split '\t'
		if tmp[0].length is 42
			res += "#{id}\t#{tmp[0]}\t#{tmp[1]}\n"
			id += 1
			summ += parseInt(tmp[1])
		else
			log tmp

	log file_name, summ

	await fs.writeFile res_file_name, res


read_vesting = (file_name, res_file_name)->
	res = await fs.readFile file_name
	res = String res
	arr = res.split '\r\n'

	time = 1544572800

	id = 1700
	res = ''
	summ = 0
	for val in arr
		tmp = val.split '\t'
#		if tmp[1].length is 42
#			vesting_time = time + parseInt(tmp[3]) * 30 * 24 * 60 * 60
#			res += "#{id}\t#{tmp[0]}\t#{tmp[1]}\t#{tmp[2]}\t#{vesting_time}\n"
		if tmp[0].length is 42
			vesting_time = time + parseInt(tmp[2]) * 30 * 24 * 60 * 60
			res += "#{id}\t#{id}\t#{tmp[0]}\t#{tmp[1]}\t#{vesting_time}\n"
			id += 1
			summ += parseInt(tmp[1])

	log file_name, summ


	await fs.writeFile res_file_name, res


read_sum = (file_name, spl, pos)->
	res = await fs.readFile file_name
	res = String res
	arr = res.split spl

	strings = 0

	summ = 0
	for val in arr
		tmp = val.split '\t'
		if tmp.length is 1
			tmp = val.split '  '

		summ += parseInt(tmp[pos])

	log file_name, summ
