/*
 *
 * (C) 2013-22 - ntop.org
 *
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 *
 */

#include "ntop_includes.h"

#ifndef HAVE_NEDGE

/* **************************************************** */

ExportInterface::ExportInterface(const char *_endpoint, const char *_topic) {
  topic = strdup(_topic), endpoint = strdup(_endpoint);

  if((context = zmq_ctx_new()) == NULL) {
    const char *msg = "Unable to initialize ZMQ context";
    ntop->getTrace()->traceEvent(TRACE_ERROR, msg);
    throw(msg);
  }

  if((publisher = zmq_socket(context, ZMQ_PUB)) == NULL) {
    const char *msg = "Unable to create ZMQ socket";
    ntop->getTrace()->traceEvent(TRACE_ERROR, msg);
    throw(msg);
  }

#if ZMQ_VERSION >= ZMQ_MAKE_VERSION(4,1,0)
  if (ntop->getPrefs()->get_export_zmq_encryption_key()) {
    const char *server_public_key = ntop->getPrefs()->get_export_zmq_encryption_key();
    char client_public_key[41];
    char client_secret_key[41];
    int rc;

    rc = zmq_curve_keypair(client_public_key, client_secret_key);

    if (rc != 0) {
      const char *msg = "Error generating ZMQ client key pair";
      ntop->getTrace()->traceEvent(TRACE_ERROR, msg);
      throw(msg);
    }

    if (strlen(server_public_key) != 40) {
      ntop->getTrace()->traceEvent(TRACE_ERROR, "Bad ZMQ server public key size (%lu != 40) '%s'", 
        strlen(server_public_key), server_public_key);
      throw("Bad ZMQ server public key size");
    }

    rc = zmq_setsockopt(publisher, ZMQ_CURVE_SERVERKEY,
      server_public_key, strlen(server_public_key)+1);

    if (rc != 0) {
      ntop->getTrace()->traceEvent(TRACE_ERROR, "Error setting ZMQ_CURVE_SERVERKEY = %s (%d)", 
        server_public_key, errno);
      throw("Error setting ZMQ_CURVE_SERVERKEY");
    }

    rc = zmq_setsockopt(publisher, ZMQ_CURVE_PUBLICKEY,
      client_public_key, strlen(client_public_key)+1);

    if (rc != 0) {
      ntop->getTrace()->traceEvent(TRACE_ERROR, "Error setting ZMQ_CURVE_PUBLICKEY = %s",
        client_public_key);
      throw("Error setting ZMQ_CURVE_PUBLICKEY");
    }

    rc = zmq_setsockopt(publisher, ZMQ_CURVE_SECRETKEY, client_secret_key, 
      strlen(client_secret_key)+1);

    if (rc != 0) {
      ntop->getTrace()->traceEvent(TRACE_ERROR, "Error setting ZMQ_CURVE_SECRETKEY = %s",
        client_secret_key);
      throw("Error setting ZMQ_CURVE_SECRETKEY");
    }
  }
#endif

  if(zmq_bind(publisher, endpoint) != 0) {
    ntop->getTrace()->traceEvent(TRACE_ERROR, "Unable to bind ZMQ endpoint %s: %s",
      endpoint, strerror(errno));
    throw("Unable to bind ZMQ endpoint");
  }

  ntop->getTrace()->traceEvent(TRACE_NORMAL, "Successfully created ZMQ endpoint %s", endpoint);
}

/* **************************************************** */

ExportInterface::~ExportInterface() {
  if(topic)    free(topic);
  if(endpoint) free(endpoint);

  zmq_close(publisher);
  zmq_ctx_destroy(context);
}

/* **************************************************** */

void ExportInterface::export_data(char *json) {
  if(publisher) {
    struct zmq_msg_hdr_v1 msg_hdr;

    snprintf(msg_hdr.url, sizeof(msg_hdr.url), "%s", topic);
    msg_hdr.version = ZMQ_MSG_VERSION, msg_hdr.size = (u_int32_t)strlen(json);

    zmq_send(publisher, &msg_hdr, sizeof(msg_hdr), ZMQ_SNDMORE);
    zmq_send(publisher, json, msg_hdr.size, 0);
    ntop->getTrace()->traceEvent(TRACE_INFO, "[ZMQ] %s", json);
  }
}

/* **************************************************** */

#endif
