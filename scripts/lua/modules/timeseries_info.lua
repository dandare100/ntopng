--
-- (C) 2014-22 - ntop.org
--

local dirs = ntop.getDirs()
package.path = dirs.installdir .. "/scripts/lua/modules/?.lua;" .. package.path

local ts_utils = require "ts_utils_core"

local timeseries_utils = {}

-- #################################

local series_extra_info = {
  alerts = {
    color = '#2d99bd'
  },
  bytes = {
    color = '#ffc046'
  },
  bytes_sent = {
    color = '#c6d9fd'
  },
  bytes_rcvd = {
    color = '#09ee09'
  },
  devices = {
    color = '#ac9ddf'
  },
  flows = {
    color = '#8c6f94'
  },
  hosts = {
    color = '#ff7f0e'
  },
  score = {
    color = '#ff3231'
  },
  cli_score = {
    color = '#690504'
  },
  srv_score = {
    color = '#f5a2a2'
  },
  default = {
    color = '#c6d9fd'
  }
}

-- #################################

function timeseries_utils.get_timeseries_color(subject)
  if series_extra_info[subject] then
    return series_extra_info[subject].color
  end

  -- Safety check, if an improper value is given, 
  -- then return a default color
  return series_extra_info.default.color
end

-- #################################

-- Timeseries list
local community_timeseries = {
  { schema = "iface:flows",                   label = i18n("graphs.active_flows"),              measure_unit = "number", scale = 0, timeseries = { num_flows          = { label = i18n('graphs.metric_labels.num_flows'),   color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "iface:new_flows",               label = i18n("graphs.new_flows"),                 measure_unit = "fps",    scale = 0, timeseries = { new_flows          = { label = i18n('graphs.metric_labels.num_flows'),   color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "iface:alerted_flows",           label = i18n("graphs.total_alerted_flows"),       measure_unit = "number", scale = 0, timeseries = { num_flows          = { label = i18n('graphs.metric_labels.num_flows'),   color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "iface:hosts",                   label = i18n("graphs.active_hosts"),              measure_unit = "number", scale = 0, timeseries = { num_hosts          = { label = i18n('graphs.metric_labels.num_hosts'),   color = timeseries_utils.get_timeseries_color('hosts') }}},
  { schema = "iface:engaged_alerts",          label = i18n("graphs.engaged_alerts"),            measure_unit = "number", scale = 0, timeseries = { engaged_alerts     = { label = i18n('graphs.engaged_alerts'),            color = timeseries_utils.get_timeseries_color('alerts') }}},
  { schema = "iface:dropped_alerts",          label = i18n("graphs.dropped_alerts"),            measure_unit = "number", scale = 0, timeseries = { dropped_alerts     = { label = i18n('graphs.dropped_alerts'),            color = timeseries_utils.get_timeseries_color('alerts') }}},
  { schema = "iface:devices",                 label = i18n("graphs.active_devices"),            measure_unit = "number", scale = 0, timeseries = { num_devices        = { label = i18n('graphs.metric_labels.num_devices'), color = timeseries_utils.get_timeseries_color('devices') }}},
  { schema = "iface:http_hosts",              label = i18n("graphs.active_http_servers"),       measure_unit = "number", scale = 0, timeseries = { num_devices        = { label = i18n('graphs.metric_labels.num_servers'), color = timeseries_utils.get_timeseries_color('devices') }},  nedge_exclude = true },
  { schema = "iface:traffic",                 label = i18n("graphs.traffic"),                   measure_unit = "bps",    scale = 0, timeseries = { bytes              = { label = i18n('graphs.metric_labels.traffic'),     color = timeseries_utils.get_timeseries_color('devices') }},  nedge_exclude = true },
  { schema = "iface:score",                   label = i18n("graphs.score"),                     measure_unit = "number", scale = 0, timeseries = { cli_score          = { label = i18n('graphs.cli_score'),                 color = timeseries_utils.get_timeseries_color('cli_score') },   srv_score = { label = i18n('graphs.srv_score'), color = timeseries_utils.get_timeseries_color('srv_score') }}},
  { schema = "iface:traffic_rxtx",            label = i18n("graphs.traffic_rxtx"),              measure_unit = "bps",    scale = 0, timeseries = { bytes_sent         = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('bytes_sent') },  bytes_rcvd = { invert_direction = true, label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('bytes_rcvd') }}},
  { schema = "iface:packets_vs_drops",        label = i18n("graphs.packets_vs_drops"),          measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.metric_labels.packets'),     color = timeseries_utils.get_timeseries_color('packets') },     drops = { label = i18n('graphs.metric_labels.drops'), color = timeseries_utils.get_timeseries_color('default') }}},
  { schema = "iface:nfq_pct",                 label = i18n("graphs.num_nfq_pct"),               measure_unit = "number", scale = 0, timeseries = { num_nfq_pct        = { label = i18n('graphs.num_nfq_pct'),               color = timeseries_utils.get_timeseries_color('default') }},  nedge_only = true },
  { schema = "iface:hosts_anomalies",         label = i18n("graphs.hosts_anomalies"),           measure_unit = "number", scale = 0, timeseries = { num_loc_hosts_anom = { label = i18n('graphs.loc_host_anomalies'),        color = timeseries_utils.get_timeseries_color('hosts') },       num_rem_hosts_anom = { label = i18n('graphs.rem_host_anomalies'), color = timeseries_utils.get_timeseries_color('hosts') }}},
  { schema = "iface:disc_prob_bytes",         label = i18n("graphs.discarded_probing_bytes"),   measure_unit = "bps",    scale = 0, timeseries = { bytes              = { label = i18n('graphs.metric_labels.drops'),       color = timeseries_utils.get_timeseries_color('bytes') }},    nedge_exclude = true },
  { schema = "iface:disc_prob_pkts",          label = i18n("graphs.discarded_probing_packets"), measure_unit = "pps",    scale = 0, timeseries = { packets            = { label = i18n('graphs.metric_labels.drops'),       color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:dumped_flows",            label = i18n("graphs.dumped_flows"),              measure_unit = "pps",    scale = 0, timeseries = { dumped_flows       = { label = i18n('graphs.dumped_flows'),              color = timeseries_utils.get_timeseries_color('flows') },       dropped_flows = { label = i18n('graphs.dumped_flows'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "iface:zmq_recv_flows",          label = i18n("graphs.zmq_received_flows"),        measure_unit = "number", scale = 0, timeseries = { flows              = { label = i18n('graphs.zmq_received_flows'),        color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "iface:zmq_flow_coll_drops",     label = i18n("graphs.zmq_flow_coll_drops"),       measure_unit = "number", scale = 0, timeseries = { drops              = { label = i18n('graphs.zmq_flow_coll_drops'),       color = timeseries_utils.get_timeseries_color('default') }},  nedge_exclude = true },
  { schema = "iface:zmq_flow_coll_udp_drops", label = i18n("graphs.zmq_flow_coll_udp_drops"),   measure_unit = "number", scale = 0, timeseries = { drops              = { label = i18n('graphs.zmq_flow_coll_udp_drops'),   color = timeseries_utils.get_timeseries_color('default') }},  nedge_exclude = true },
  { schema = "iface:tcp_lost",                label = i18n("graphs.tcp_packets_lost"),          measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_packets_lost'),          color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_out_of_order",        label = i18n("graphs.tcp_packets_ooo"),           measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_packets_ooo'),           color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_retransmissions",     label = i18n("graphs.tcp_packets_retr"),          measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_packets_retr'),          color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_keep_alive",          label = i18n("graphs.tcp_packets_keep_alive"),    measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_packets_keep_alive'),    color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_syn",                 label = i18n("graphs.tcp_syn_packets"),           measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_syn_packets'),           color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_synack",              label = i18n("graphs.tcp_synack_packets"),        measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_syn_packets'),           color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_finack",              label = i18n("graphs.tcp_finack_packets"),        measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_finack_packets'),        color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "iface:tcp_rst",                 label = i18n("graphs.tcp_rst_packets"),           measure_unit = "number", scale = 0, timeseries = { packets            = { label = i18n('graphs.tcp_rst_packets'),           color = timeseries_utils.get_timeseries_color('packets') }},  nedge_exclude = true },
  { schema = "host:traffic",                  label = i18n("graphs.traffic"),                   measure_unit = "bps",    scale = 0, timeseries = { bytes_sent         = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('bytes_sent') },  bytes_rcvd = { invert_direction = true, label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('bytes_rcvd') }}},
  { schema = "host:score",                    label = i18n("graphs.score"),                     measure_unit = "number", scale = 0, timeseries = { cli_score          = { label = i18n('graphs.cli_score'),                 color = timeseries_utils.get_timeseries_color('cli_score') },   srv_score = { label = i18n('graphs.srv_score'), color = timeseries_utils.get_timeseries_color('srv_score') }}},
  { schema = "host:active_flows",             label = i18n("graphs.active_flows"),              measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:total_flows",              label = i18n("graphs.total_flows"),               measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:num_blacklisted_flows",    label = i18n("graphs.num_blacklisted_flows"),     measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:alerted_flows",            label = i18n("graphs.total_alerted_flows"),       measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:unreachable_flows",        label = i18n("graphs.total_unreachable_flows"),   measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:host_unreachable_flows",   label = i18n("graphs.host_unreachable_flows"),    measure_unit = "fps",    scale = 0, timeseries = { flows_as_client    = { label = i18n('graphs.flows_as_client'),           color = timeseries_utils.get_timeseries_color('flows') },       flows_as_server = { label = i18n('graphs.flows_as_server'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:contacts",                 label = i18n("graphs.active_host_contacts"),      measure_unit = "fps",    scale = 0, timeseries = { num_as_clients     = { label = i18n('graphs.metric_labels.as_cli'),      color = timeseries_utils.get_timeseries_color('flows') },       num_as_server   = { label = i18n('graphs.metric_labels.as_srv'), color = timeseries_utils.get_timeseries_color('flows') }}},
  { schema = "host:contacts_behaviour",       label = i18n("graphs.host_contacts_behaviour"),   measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') },       lower_bound     = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "host:total_alerts",             label = i18n("graphs.alerts"),                    measure_unit = "number", scale = 0, timeseries = { alerts             = { label = i18n('graphs.tcp_rst_packets'),           color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:engaged_alerts",           label = i18n("graphs.engaged_alerts"),            measure_unit = "number", scale = 0, timeseries = { alerts             = { label = i18n('graphs.tcp_rst_packets'),           color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:dns_qry_sent_rsp_rcvd",    label = i18n("graphs.dns_qry_sent_rsp_rcvd"),     measure_unit = "number", scale = 0, timeseries = { queries_pkts       = { label = i18n('graphs.metric_labels.queries_pkts'),color = timeseries_utils.get_timeseries_color('default') },     replies_ok_pkts = { label = i18n('graphs.metric_labels.ok_pkts'), color = timeseries_utils.get_timeseries_color('default') }, replies_error_pkts = { label = i18n('graphs.metric_labels.error_pkts'), color = timeseries_utils.get_timeseries_color('default') }}},
  { schema = "host:dns_qry_rcvd_rsp_sent",    label = i18n("graphs.dns_qry_rcvd_rsp_sent"),     measure_unit = "number", scale = 0, timeseries = { queries_pkts       = { label = i18n('graphs.metric_labels.queries_pkts'),color = timeseries_utils.get_timeseries_color('default') },     replies_ok_pkts = { label = i18n('graphs.metric_labels.ok_pkts'), color = timeseries_utils.get_timeseries_color('default') }, replies_error_pkts = { label = i18n('graphs.metric_labels.error_pkts'), color = timeseries_utils.get_timeseries_color('default') }}},
  { schema = "host:tcp_rx_stats",             label = i18n("graphs.tcp_rx_stats"),              measure_unit = "pps",    scale = 0, timeseries = { retran_pkts        = { label = i18n('graphs.metric_labels.retra_pkts'),  color = timeseries_utils.get_timeseries_color('packets') },     out_of_order_pkts = { label = i18n('graphs.metric_labels.ooo_pkts'), color = timeseries_utils.get_timeseries_color('packets') }, lost_packets = { label = i18n('graphs.metric_labels.lost_pkts'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:tcp_tx_stats",             label = i18n("graphs.tcp_tx_stats"),              measure_unit = "pps",    scale = 0, timeseries = { retran_pkts        = { label = i18n('graphs.metric_labels.retra_pkts'),  color = timeseries_utils.get_timeseries_color('packets') },     out_of_order_pkts = { label = i18n('graphs.metric_labels.ooo_pkts'), color = timeseries_utils.get_timeseries_color('packets') }, lost_packets = { label = i18n('graphs.metric_labels.lost_pkts'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:udp_pkts",                 label = i18n("graphs.udp_packets"),               measure_unit = "pps",    scale = 0, timeseries = { packets_sent       = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('packets') },     packets_rcvd    = { label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:echo_reply_packets",       label = i18n("graphs.echo_reply_packets"),        measure_unit = "pps",    scale = 0, timeseries = { packets_sent       = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('packets') },     packets_rcvd    = { label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:echo_packets",             label = i18n("graphs.echo_request_packets"),      measure_unit = "pps",    scale = 0, timeseries = { packets_sent       = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('packets') },     packets_rcvd    = { label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:tcp_packets",              label = i18n("graphs.tcp_packets"),               measure_unit = "pps",    scale = 0, timeseries = { packets_sent       = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('packets') },     packets_rcvd    = { label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('packets') }}},
  { schema = "host:udp_sent_unicast",         label = i18n("graphs.udp_sent_unicast_vs_non_unicast"), measure_unit = "bps", scale = 0, timeseries = { bytes_sent_unicast = { label = i18n('graphs.metric_labels.sent_uni'), color = timeseries_utils.get_timeseries_color('bytes') },       bytes_sent_non_uni = { label = i18n('graphs.metric_labels.sent_non_uni'), color = timeseries_utils.get_timeseries_color('bytes') }}},
  { schema = "host:dscp",                     label = i18n("graphs.dscp_classes"),              measure_unit = "bps",    scale = 0, timeseries = { bytes_sent         = { label = i18n('graphs.metric_labels.sent'),        color = timeseries_utils.get_timeseries_color('bytes') },       bytes_rcvd      = { label = i18n('graphs.metric_labels.rcvd'), color = timeseries_utils.get_timeseries_color('bytes') }}},
}

local pro_timeseries = {
  { schema = "iface:score_anomalies",         label = i18n("graphs.iface_score_anomalies"),     measure_unit = "number", scale = 0, timeseries = { anomaly            = { label = i18n('graphs.iface_score_anomalies'),     color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "iface:traffic_anomalies",       label = i18n("graphs.iface_traffic_anomalies"),   measure_unit = "number", scale = 0, timeseries = { anomaly            = { label = i18n('graphs.iface_traffic_anomalies'),   color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "iface:score_behavior",          label = i18n("graphs.iface_score_behavior"),      measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "iface:local_hosts",             label = i18n("graphs.iface_active_local_hosts"),  measure_unit = "number", scale = 0, timeseries = { num_hosts          = { label = i18n('graphs.metrics_prefixes.num_hosts'),color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "iface:traffic_rx_behavior_v2",  label = i18n("graphs.iface_traffic_rx_behavior"), measure_unit = "bps",    scale = 0, timeseries = { value              = { label = i18n('graphs.traffic_rcvd'),              color = timeseries_utils.get_timeseries_color('bytes') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('bytes') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('bytes') }}, nedge_exclude = true },
  { schema = "iface:traffic_tx_behavior_v2",  label = i18n("graphs.iface_traffic_tx_behavior"), measure_unit = "bps",    scale = 0, timeseries = { value              = { label = i18n('graphs.traffic_sent'),              color = timeseries_utils.get_timeseries_color('bytes') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('bytes') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('bytes') }}, nedge_exclude = true },
  { schema = "iface:score_behavior",          label = i18n("graphs.iface_score_behavior"),      measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "iface:behavioural_maps",        label = i18n("graphs.behavioural_maps"),          measure_unit = "number", scale = 0, timeseries = { period_map_entries = { label = i18n('graphs.periodicity_map_entries'),   color = timeseries_utils.get_timeseries_color('default') }, svc_map_entries = { label = i18n('graphs.service_map_entries'), color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "host:srv_score_anomalies",      label = i18n("graphs.srv_score_anomalies"),       measure_unit = "number", scale = 0, timeseries = { anomaly            = { label = i18n('graphs.iface_traffic_anomalies'),   color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "host:cli_score_anomalies",      label = i18n("graphs.cli_score_anomalies"),       measure_unit = "number", scale = 0, timeseries = { anomaly            = { label = i18n('graphs.iface_traffic_anomalies'),   color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "host:score_behavior",           label = i18n("graphs.iface_score_behavior"),      measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "host:srv_score_behaviour",      label = i18n("graphs.srv_score_behaviour"),       measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "host:cli_score_behaviour",      label = i18n("graphs.cli_score_behaviour"),       measure_unit = "number", scale = 0, timeseries = { value              = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "host:srv_active_flows_anomalies", label = i18n("graphs.srv_active_flows_anomalies"), measure_unit = "number", scale = 0, timeseries = { anomaly         = { label = i18n('graphs.iface_traffic_anomalies'),   color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "host:cli_active_flows_anomalies", label = i18n("graphs.cli_active_flows_anomalies"), measure_unit = "number", scale = 0, timeseries = { anomaly         = { label = i18n('graphs.iface_traffic_anomalies'),   color = timeseries_utils.get_timeseries_color('default') }}, nedge_exclude = true },
  { schema = "host:cli_active_flows_behaviour", label = i18n("graphs.srv_active_flows_behaviour"), measure_unit = "number", scale = 0, timeseries = { value           = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
  { schema = "host:srv_active_flows_behaviour", label = i18n("graphs.srv_active_flows_behaviour"), measure_unit = "number", scale = 0, timeseries = { value           = { label = i18n('graphs.score'),                     color = timeseries_utils.get_timeseries_color('score') }, lower_bound = { label = i18n('graphs.lower_bound'), color = timeseries_utils.get_timeseries_color('score') }, upper_bound = { label = i18n('graphs.upper_bound'), color = timeseries_utils.get_timeseries_color('score') }}, nedge_exclude = true },
}

-- #################################

local function retrieve_specific_timeseries(prefix)
  local timeseries_list = community_timeseries
  if ntop.isPro() then
    timeseries_list = table.merge(community_timeseries, pro_timeseries)
  end

  for index, info in pairs(timeseries_list) do
    -- Check if the schema starts with 'iface:', 
    -- if not then it's not an interface timeseries, so drop it
    if not string.starts(info.schema, prefix) then
      table.remove(timeseries_list, index)
      goto skip
    end

    -- Remove from nEdge the timeseries only for ntopng
    if (info.nedge_exclude) and (ntop.isnEdge()) then
      table.remove(timeseries_list, index)
      goto skip
    end

    -- Remove from ntopng the timeseries only for nEdge
    if (info.nedge_only) and (not ntop.isnEdge()) then
      table.remove(timeseries_list, index)
      goto skip
    end

    -- Remove if the timeseries does not exists
    if not ts_utils.exists(info.schema, {}) then
      table.remove(timeseries_list, index)
      goto skip
    end

    ::skip::
  end

  return timeseries_list  
end

-- #################################

function timeseries_utils.get_interface_timeseries()
  return retrieve_specific_timeseries('iface:')
end

-- #################################

function timeseries_utils.get_host_timeseries()
  return retrieve_specific_timeseries('host:')
end

-- #################################

return timeseries_utils
