# Copyright (c) 2008-2013 Michael Dvorkin and contributors.
#
# Fat Free CRM is freely distributable under the terms of MIT license.
# See MIT-LICENSE file or http://www.opensource.org/licenses/mit-license.php
#------------------------------------------------------------------------------
class UserMailer < ActionMailer::Base
  def password_reset_instructions(user)
    @edit_password_url = edit_password_url(user.perishable_token)

    mail subject: "Fat Free CRM: " + I18n.t(:password_reset_instruction),
         to: user.email,
         from: from_address,
         date: Time.now
  end

  def assigned_entity_notification(entity, assigner)
    @entity_url = url_for(entity)
    @entity_name = entity.name
    @entity_type = entity.class.name
    @assigner_name = assigner.name
    mail subject: "Fat Free CRM: You have been assigned #{@entity_name} #{@entity_type}",
         to: entity.assignee.email,
         from: from_address
  end

  def new_signup_notification(admin, new_user)
    @new_email = new_user.email
    mail subject: "#{new_user.email} wants to create an account",
         to: admin.email,
         from: from_address
  end

  def inactive_accounts(user)
    @inactive_accounts = user.salesperson_check
    user.email == "jorge@sustainableharvest.com" ? @jorge = nil : @jorge = "jorge@sustainableharvest.com"
    mail subject: "List of Accounts Needing Followup",
         to: user.email,
         from: from_address,
         bcc: @jorge
  end

  private

  def from_address
    from = (Setting.smtp || {})[:from]
    !from.blank? ? from : "Fat Free CRM <noreply@fatfreecrm.com>"
  end
end
