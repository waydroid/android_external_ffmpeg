static const AVFilter * const filter_list[] = {
    &ff_vf_deinterlace_vaapi,
    &ff_vf_scale,
    &ff_vf_scale_vaapi,
    &ff_vf_yadif,
    &ff_asrc_abuffer,
    &ff_vsrc_buffer,
    &ff_asink_abuffer,
    &ff_vsink_buffer,
    NULL };
