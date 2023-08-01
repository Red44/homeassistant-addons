#!/usr/bin/with-contenv bashio

# ==============================================================================
# Home Assistant Community Add-on: Bore from ekzhang                           #
# Configures the Bore client                                                   #
# Bore https://github.com/ekzhang/bore                                         #
# Provided by https://github.com/Red44                                         #
# Repo https://github.com/Red44/homeassistant-addons/tree/bore                 #
# ==============================================================================

if [ -f "/usr/bin/bore" ]; then
  bashio::log.info "Bore has been successfully installed"
else
  bashio::log.fatal "Bore has not been installed, please report this issue"
  bashio::exit.nok "Plugin installation failed"
fi

if bashio::config.has_value 'port'; then
  PORT=$(bashio::config 'port')
  bashio::log.info "Using port ${PORT}"
else
  PORT=8123
  bashio::log.warning "Using default port ${PORT}"
fi

if bashio::config.has_value 'outgoing_port_reverse_proxy'; then
  OUTGOING_PORT_REVERSE_PROXY=$(bashio::config 'outgoing_port_reverse_proxy')
  bashio::log.info "Using outgoing port ${OUTGOING_PORT_REVERSE_PROXY} for reverse proxy"
else
  OUTGOING_PORT_REVERSE_PROXY=PORT
  bashio::log.warning "Using Host define Port as outgoing port ${OUTGOING_PORT_REVERSE_PROXY} for reverse proxy"
fi

if bashio::config.has_value 'ip'; then
  IP=$(bashio::config 'ip')
else
  bashio::log.fatal 'No IP address specified'
  bashio::exit.nok 'Specificity an IP address inside your configuration file'
fi

if bashio::config.has_value 'fallback_ip'; then
  FALLBACK_IP=$(bashio::config 'fallback_ip')
else
  bashio::log.warning 'No fallback IP address specified using IP address'
  FALLBACK_IP=$IP
fi

if bashio::config.has_value 'secret'; then
  SECRET=$(bashio::config 'secret')
  NO_SECRET=false
  bashio::log.info "Using secret ********"
else
  bashio::log.warning 'No secret specified'
  NO_SECRET=true
fi

if bashio::config.has_value 'retries'; then
  RETRIES=$(bashio::config 'retries')
  bashio::log.info "On disconnect $RETRIES retries will be attempted"
else
  bashio::log.warning 'No retries specified'
  RETRIES=5
fi

if bashio::config.has_value 'relentless'; then
  RELENTLESS=$(bashio::config 'relentless')
  bashio::log.info "Relentless mode is $RELENTLESS"
else
  bashio::log.warning 'Relentlessness not specified default will be set to false'
  RELENTLESS=false
fi

bashio::log.info "Starting bore"

while [[ $RETRIES -gt 0 ]] || [[ $RELENTLESS = true ]]; do
  if [ "$NO_SECRET" = true ]; then
    bashio::log.info "Ensure that on $IP (+fallback)a bore server is running [bore server]"
    nohup bore local $PORT --port $OUTGOING_PORT_REVERSE_PROXY --to "$IP" &

  else
    bashio::log.info "Ensure that on $IP (+fallback)a bore server is running with secret [bore server --secret YOUR_SECRET]"
    bore local $PORT --port $OUTGOING_PORT_REVERSE_PROXY --to "$IP" --secret "$SECRET" &
  fi
  wait $!
  bashio::log.error "Main IP not available, attempting fallback IP"
  bashio::log.info "Attempting fallback bore server connection"
  if [ "$NO_SECRET" = true ]; then
    nohub bore local $PORT --port $OUTGOING_PORT_REVERSE_PROXY --to "$IP" &
  else
    nohub bore local $PORT --port $OUTGOING_PORT_REVERSE_PROXY --to "$IP" --secret "$SECRET" &
  fi
  wait $!
  bashio::log.error "Fallback IP not available, retires left $RETRIES"
  if [ $RELENTLESS = false ]; then
    RETRIES=$((RETRIES - 1))
  fi
done

bashio::exit.nok "The client has stopped or was not able to connect to the server"
