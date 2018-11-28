    jQuery && jQuery.fn.extend({'xform':function(action){
        form = this[0];
        form.old_action=form.action,form.old_target=form.target,form.action=action;
        var iframe = jQuery('