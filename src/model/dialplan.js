/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:38 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:38 
 */
import bookshelf from '../bookshelf';

const Dialplan = bookshelf.Model.extend({
    tableName: 'dialplans',
});

module.exports = bookshelf.model('Dialplan', Dialplan);
