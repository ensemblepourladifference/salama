/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:38 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:38 
 */
import bookshelf from '../bookshelf';

const Emergency = bookshelf.Model.extend({
    tableName: 'emergencies'
});

module.exports = bookshelf.model('Emergency', Emergency);
