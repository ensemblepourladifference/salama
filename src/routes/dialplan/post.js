/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:12 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 12:35:28
 */

const Boom = require('boom');
const Dialplan = require('../../model/dialplan');

module.exports = (request, reply) => {

    new Dialplan(request.payload)
        .save()
        .then((dialplan) => {

            const responseData = {
                message: 'dialplan success',
                dialplan
            };
            reply(responseData);
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on dialplan ' + err));
            }
        });

};
