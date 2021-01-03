


                  <tbody>
                  <% attendances = Attendance.where(user_id: user.id).where(overtime_status: "申請中") %>
                  <% attendances.each do |attendance| %>
                  <%= f.fields_for "attendances[]", attendance do |at| %>
                      
                          <tr>
                            <td class="center"><%= l(attendance.worked_on, format: :short) %></td>
                            <td class="center">
                              <% if attendance.worked_on.wday == 0 %>
                          <font color="#ff000">
                        <% elsif attendance.worked_on.wday == 6 %>
                          <font color="#0033cc">
                        <% end %>
                        <%= $days_of_the_week[attendance.worked_on.wday] %>
                            </td>
                            <td class="center"><%= l(attendance.overtime_end_plan, format: :time) %></td>
                            <td class="center"><%= l(user.designated_work_end_time, format: :time) %></td>
                            <td class="center"><%= format("%.2f", attendance.overtime_hour.to_f.floor_to(0.25)) %></td>
                            <td class="center"><%= attendance.overtime_detail %></td>
                             <td class="center">
                          <%= at.select :overtime_status, ['','申請中', '承認', '否認'], {}, class: "form-control" %>
                        </td>
                        <td class="center">
                          <%= at.check_box :overtime_check %>
                          <%= at.hidden_field :overtime_approval, value: 3 %>
                        </td>
                            <td class="center">
                              <%= link_to "確認", user_path(user, date: attendance.worked_on), class: "btn btn-primary btn-overtime_check" %>
                            </td>
                          </tr>

                          
                       
                     
                    
                  </tbody>

                <% end %>
                <% end %>
                
                </table>
               
            <% end %>
           <div class="text-center">
           <%= f.submit "変更を送信する", class: "btn btn-primary btn-lg btn-overtime-change" %>
           </div>
            

          </div>

        </div>
      </div>
       
    </div>
    
  </div>

<% end %>
