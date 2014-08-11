class MembersController < ApplicationController
  def index
    @sort = params[:sort]
    # By default sort by last name
    @sort = "lastname" if @sort.nil?

    @house = params[:house]
    @house = "representatives" if @house.nil?

    @parliament = params[:parliament]

    order = case @sort
    when "lastname"
      ["last_name", "first_name", "constituency", "party", "entered_house DESC"]
    when "constituency"
      ["constituency", "last_name", "first_name", "party", "entered_house DESC"]
    when "party"
      ["party", "last_name", "first_name", "constituency", "entered_house DESC"]
    when "rebellions"
      ["rebellions_fraction DESC", "last_name", "first_name", "constituency", "party", "entered_house DESC"]
    when "attendance"
      ["attendance_fraction DESC", "last_name", "first_name", "constituency", "party", "entered_house DESC"]
    when "date"
      ["left_house", "last_name", "first_name", "constituency", "party", "entered_house DESC"]
    else
      raise "Unexpected value"
    end

    # FIXME: Should be easy to refactor this, just doing the dumb thing right now
    member_info_join = 'LEFT OUTER JOIN `pw_cache_mpinfo` ON `pw_cache_mpinfo`.`mp_id` = `pw_mp`.`mp_id`'
    if @parliament.nil?
      @members = Member.current.in_australian_house(@house).joins(member_info_join).select("*, round(votes_attended/votes_possible,10) as attendance_fraction, round(rebellions/votes_attended,10) as rebellions_fraction").order(order)
    elsif @parliament == "all"
      @members = Member.in_australian_house(@house).joins(member_info_join).select("*, round(votes_attended/votes_possible,10) as attendance_fraction, round(rebellions/votes_attended,10) as rebellions_fraction").order(order)
    elsif Parliament.all[@parliament]
      @members = Member.where("? >= entered_house AND ? < left_house", Parliament.all[@parliament][:to], Parliament.all[@parliament][:from]).in_australian_house(@house).joins(member_info_join).select("*, round(votes_attended/votes_possible,10) as attendance_fraction, round(rebellions/votes_attended,10) as rebellions_fraction").order(order)
    else
      raise
    end

    if params[:bs]
      render "members/bootstrap/index", layout: "bootstrap"
    else
      render "index"
    end
  end

  def show
    electorate = params[:mpc].gsub("_", " ") if params[:mpc]
    name = params[:mpn].gsub("_", " ") if params[:mpn]
    @display = params[:showall] == "yes" ? "allvotes" : params[:display]

    if params[:mpid]
      @member = Member.find_by!(mp_id: params[:mpid])
    elsif params[:id]
      @member = Member.find_by!(gid: params[:id])
    elsif name
      @member = Member.with_name(name)
      @member = @member.in_australian_house(params[:house]) if params[:house]
      @member = @member.where(constituency: electorate) if electorate && electorate != "Senate"
      @member = @member.order(entered_house: :desc).first
    end

    if @member
      @members = Member.where(person: @member.person).order(entered_house: :desc)

      # Trying this hack. Seems mighty weird
      # TODO Get rid of this
      @member = @members.first if @member.senator?
    else
      @members = Member.where(constituency: electorate).order(entered_house: :desc)
      @members = @members.in_australian_house(params[:house]) if params[:house]
      @member = @members.first
      # TODO If this relates to a single person redirect
    end

    if @member.nil?
      # TODO: This should 404 but doesn't to match the PHP app
      render 'member_not_found'
      return
    end

    if params[:dmp]
      @policy = Policy.find(params[:dmp])
      # Pick the member where the votes took place
      @member = @member.person_object.member_for_policy(@policy)
      # Not using PolicyMemberDistance.find_by because of the messed up association with the Member model
      unless @policy_member_distance = @member.policy_member_distances.find_by(policy: @policy)
        @policy_member_distance = PolicyMemberDistance.new
      end
      @agreement_fraction_with_policy = @member.agreement_fraction_with_policy(@policy)
      @number_of_votes_on_policy = @member.number_of_votes_on_policy(@policy)
    end

    if @policy
      render "show_policy"
    else
      if params[:bs]
        render "members/bootstrap/show", layout: "bootstrap"
      else
        render "show"
      end
    end
  end
end