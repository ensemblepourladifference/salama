/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:08 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:08 
 */

const Boom = require('boom');
const User = require('../../model/user');

module.exports = (request, reply) => {



    User
        .where('id', request.params.id)
        .fetch()
        .then((user) => {

            user
                .save(request.payload)
                .then((updated) => {

                    const responseData = {
                        message: 'user updated',
                        updated
                    };
                    reply(responseData);
                });
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on user ' + err));
            }
        });

};
