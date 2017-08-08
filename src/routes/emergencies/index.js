/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:16 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 13:36:42
 */

const Joi = require('joi');

const emergencyCreateSchema = Joi.object().keys({
    auditPath:  Joi.string(),
    toBeContacted:  Joi.string(),
    user_id:  Joi.number()
});


const emergencyUpdateSchema = Joi.object().keys({
    contacted:  Joi.string(),
    active:  Joi.boolean(),
    cancelled:  Joi.boolean(),
    user_id:  Joi.number()
});



exports.register = (server, options, next) => {

    server.route({

        path: '/emergencies/{id}',
        method: 'GET',
        config: {
            description: 'Route to get emergencies.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            }
        },
        handler: require('./get')
    });

    server.route({

        path: '/emergencies',
        method: 'POST',
        config: {
            description: 'Route to create emergencies.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                params: emergencyCreateSchema
            }
        },
        handler: require('./post')
    });

    server.route({

        path: '/emergencies/{id}',
        method: 'PUT',
        config: {
            description: 'Protected route to update a emergencies.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                params: {
                    id: Joi.string()
                },
                payload: {
                    cancelled: Joi.string()
                }
            }
        },
        handler: require('./put')
    });

    next();
};

exports.register.attributes = {
    name: 'emergencies-routes'
};
