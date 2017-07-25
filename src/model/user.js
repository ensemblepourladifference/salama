/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:38 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:38 
 */
import bookshelf from '../bookshelf';

const Dialplans = bookshelf.Model.extend({
    tableName: 'dialplans'
});

const User = bookshelf.Model.extend({
    tableName: 'users',
    dialplans: function () {

        return this.hasMany(Dialplans, 'user_id');
    },
    hasTimestamps: true
});

module.exports = bookshelf.model('User', User);
