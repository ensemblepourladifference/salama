/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:08 
 * @Last Modified by:   Euan Millar 
 * @Last Modified time: 2017-07-05 01:14:08 
 */

const Boom = require('boom');
const Emergency = require('../../model/emergency');

module.exports = (request, reply) => {


    console.log('request.payload: ' + JSON.stringify(request.payload));
    Emergency
        .where('id', request.params.id)
        .fetch()
        .then((emergency) => {

            console.log('request.payload: ' + JSON.stringify(request.payload));
            emergency
                .save(request.payload)
                .then((updated) => {

                    const responseData = {
                        message: 'Emergency updated',
                        updated
                    };
                    reply(responseData);
                });
        })
        .catch((err) => {

            if (err){
                reply(Boom.badImplementation('terrible implementation on Emergency ' + err));
            }
        });

};
