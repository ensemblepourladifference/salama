/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:20 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 12:12:10
 */
const Boom = require('boom');
const User = require('../../model/user');

module.exports = (request, reply) => {

    User
        .where('id', request.params.id)
        .fetch({ withRelated:['dialplans'] })
        .then((user) => {

            if (!user) {
                reply(Boom.badRequest('No user available.'));
            }
            else {
                const responseData = {
                    message: 'user success',
                    user
                };
                reply(responseData);
            }
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on user ' + err));
            }
        });
};
