/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:12 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 12:35:28
 */

const Boom = require('boom');
const User = require('../../model/user');

module.exports = (request, reply) => {

    new User(request.payload)
        .save()
        .then((user) => {

            const responseData = {
                message: 'user success',
                user
            };
            reply(responseData);
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on user ' + err));
            }
        });

};
