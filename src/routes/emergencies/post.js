/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:12 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 12:35:28
 */

const Boom = require('boom');
const Emergency = require('../../model/emergency');

module.exports = (request, reply) => {

    new Emergency(request.payload)
        .save()
        .then((emergency) => {

            const responseData = {
                message: 'emergency success',
                emergency
            };
            reply(responseData);
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on emergency ' + err));
            }
        });

};
