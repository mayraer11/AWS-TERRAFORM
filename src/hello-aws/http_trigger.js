'use strict'

exports.handler = function(event, context, callback) {
  var response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8'
    },
    body: 'Bienvenido al AWS Community Day 2019'
  }
  callback(null, response)
}