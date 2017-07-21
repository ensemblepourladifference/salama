/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:08 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:08 
 */

const Boom = require('boom');
const Dialplan = require('../../model/dialplan');

module.exports = (request, reply) => {



    Dialplan
        .where('id', request.params.id)
        .fetch()
        .then((dialplan) => {

            dialplan
                .save(request.payload)
                .then((updated) => {

                    const responseData = {
                        message: 'dialplan updated',
                        updated
                    };
                    reply(responseData);
                });
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on dialplan ' + err));
            }
        });

};
