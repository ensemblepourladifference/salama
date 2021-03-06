/*
 * @Author: Euan Millar 
 * @Date: 2017-07-05 01:14:16 
 * @Last Modified by: Euan Millar
 * @Last Modified time: 2017-07-05 13:36:42
 */

const Joi = require('joi');



exports.register = (server, options, next) => {

    server.route({

        path: '/dialplan/{id}',
        method: 'GET',
        config: {
            description: 'Route to get dialplans.',
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

        path: '/dialplan',
        method: 'POST',
        config: {
            description: 'PRoute to create a dialplan.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                params: {
                    extensions: Joi.string()
                }
            }
        },
        handler: require('./post')
    });

    server.route({

        path: '/dialplan/{id}',
        method: 'PUT',
        config: {
            description: 'Protected route to update a dialplan.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            },
            validate: {
                params: {
                    extensions: Joi.string()
                }
            }
        },
        handler: require('./put')
    });

    server.route({

        path: '/dialplan/{id}',
        method: 'DELETE',
        config: {
            description: 'Protected route to delete an extension.',
            tags: ['api'],
            plugins: {
                'hapi-swagger': {
                    payloadType: 'form'
                }
            }
        },
        handler: require('./delete')
    });

    next();
};

exports.register.attributes = {
    name: 'dialplan-routes'
};
