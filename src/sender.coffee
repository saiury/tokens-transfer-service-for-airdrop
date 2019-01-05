keys = require '../keys.js'
fs = require('fs').promises

axios = require 'axios'


Eth = require 'ethjs'

abi = require 'ethjs-abi'


log = console.log

ether = (val)->
	Eth.fromWei val, 'ether'


wei = (val)->
	Eth.toWei val, 'ether'


bn = (val)->
	return new Eth.BN val, 10


delay = (ms)->
	return new Promise (resolve, reject)=>
		setTimeout resolve, ms

```
const getNonce = account => new Promise((resolve, reject) => {
	web3.eth.getTransactionCount(account, (err, result) => {

		if(err)
		{
			return reject(err);
		}

		resolve(result);
	});
});
```

send = ->

	sender = artifacts.require 'MassSender'
	sender_addr = '0xcdbB5a2D305f179fcfF384499cDef4D6265B3082'.toLowerCase()

	try
		res = await fs.readFile './data/5/investors_2.dat'
		res = String res
		arr = res.split '\n'
	catch err
		log err
		return

#	data = []
#	for val in arr
#		tmp = val.split '\t'
#		data.push {id: tmp[0], addr: tmp[1], amount: wei(tmp[2]).toString()}

	data = [
		{id: 3100, addr: '0x246c8e972a0FbDEF6896D97a993F8B54DD2a215C'.toLowerCase(), amount: wei('17815.9')},
		]

#	sender = await sender.deployed()

	sender = await sender.at sender_addr

	nonce = await getNonce keys.owner

	size = 2


	for i in [0...data.length] by size
		arr = data[i...i + size]
		ids = (val.id for val in arr)
		receivers = (val.addr for val in arr)
		amounts = (val.amount for val in arr)

		for j in [0..2]
			res = await sender.bulkTransfer '0xbf799a2f71d020a4a8c10e7406e2bf970b3d734b', ids, receivers, amounts, {nonce}
			log res
			nonce += 1

	await delay 1000


vesting_send = ->

	sender = artifacts.require 'MassVestingSender'

	sender_addr = '0xCBC66115e9d8655709c3408D0e320410Aef1161A'.toLowerCase()

	try
		res = await fs.readFile './data/7/vesting.dat'
		res = String res
		arr = res.split '\n'
	catch err
		log err
		return

	data = []
	for val in arr
		tmp = val.split '\t'
		data.push {id: tmp[0], addr: tmp[2], amount: wei(tmp[3]).toString(), vesting: tmp[4]}

	data = [
		{id: 1801, addr: '0x246c8e972a0FbDEF6896D97a993F8B54DD2a215C'.toLowerCase(), amount: wei('20469.99999'), vesting: '1546112999'},
		]

##	sender = await sender.deployed()

#	0xb901bdbcfe5470b854c4434b987e29ea1290dd5a
#	0x1b68e9b0dc65d5822e078667184cc0fa64b4931f
#	0xc6f695202eb1190f53a6e2b32351e1f2ef4ab78e

	sender = await sender.at sender_addr

	nonce = await getNonce keys.owner

	size = 5

	for i in [0...data.length] by size

		arr = data[i...i + size]

		ids = (val.id for val in arr)
		receivers = (val.addr.toLowerCase() for val in arr)
		amounts = (val.amount for val in arr)
		vestings = (val.vesting for val in arr)

		for j in [0...2]
			try
				res = await sender.bulkTransfer '0xbf799a2f71d020a4a8c10e7406e2bf970b3d734b', ids, receivers, amounts, vestings, {nonce}
				log res
			catch err
				log err
			nonce += 1


vesting_logs = (res_file_name)->
	try
		sender = artifacts.require 'MassVestingSender'

		sender_addr = '0xCBC66115e9d8655709c3408D0e320410Aef1161A'.toLowerCase()


		#	sender = await sender.deployed()

		sender = await sender.at sender_addr


		data = []

		vesting_transfer = sender.VestingTransfer({}, {fromBlock: 0, toBlock: 'latest'})
		vesting_transfer.get (error, logs)=>

			for val in logs

				if val.args._recipient isnt '0xacE624812a8E2d8Ff0112784BBB3dE26355b0A3B'.toLowerCase()
					if val.args._recipient isnt '0xF9c024A74938F8e9172C14dE7b513D3ce4329B49'.toLowerCase()
						data.push
							recipient: val.args._recipient
							lock: val.args._lock
							amount: ether(val.args._amount)
							vesting: val.args._vesting.toString()

			res = 'recipient;lock;amount;vesting\r\n'

			for val in data
				res += "#{val.recipient};#{val.lock};#{val.amount};#{val.vesting}\r\n"

			log data.length

			await fs.writeFile res_file_name, res

			log 'cmpl'

			return


logs = (res_file_name)->

	addr = '0xbf799a2f71d020a4a8c10e7406e2bf970b3d734b'.toLowerCase()
	sender_addr = '0x000000000000000000000000cdbb5a2d305f179fcff384499cdef4d6265b3082'.toLowerCase()
	block = 6952961
	max = 6975700

	res = 'recipient;amount\r\n'

	while block < max

		data = await axios.get "https://api.etherscan.io/api?module=logs&action=getLogs&fromBlock=#{block}&toBlock=#{block + 10}&address=#{addr}&topic1=#{sender_addr}&apikey=#{keys.APIKEY}"

		for val in data.data.result
			res += "0x#{val.topics[2][26..]};#{abi.decodeParams(['uint'], val.data)[0].toString()}\r\n"

		log block, data.statusText

		block = block + 11

		await delay 1000

	await fs.writeFile res_file_name, res

	return


logs2 = ()->

	res = await fs.readFile './data/all_log.csv'
	res = String res
	arr = res.split('\r\n')

	res = arr[0] + '\r\n'
	arr = arr[1...]

	for val in arr
		tmp = val.split ';'
		res += "#{tmp[0]};#{ether(tmp[1])}\r\n"

	await fs.writeFile './data/all_log2.csv', res

	return


#module.exports = (cb)->
#logs './data/all_log.csv'

#	vesting_send()

#logs './data/all_log.csv'

logs2()



