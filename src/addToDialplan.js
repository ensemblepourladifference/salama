
var cron = require('cron');

//var cronJob = cron.job('00 30 17 * * 0-6', function(){
var cronJob = cron.job('* */30 * * *', function(){
  addToDialplan();
});