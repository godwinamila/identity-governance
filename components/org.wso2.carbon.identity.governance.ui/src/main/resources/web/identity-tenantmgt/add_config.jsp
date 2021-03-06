<%--
  ~ Copyright (c) 2016, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
  ~
  ~ Licensed under the Apache License, Version 2.0 (the "License");
  ~ you may not use this file except in compliance with the License.
  ~ You may obtain a copy of the License at
  ~
  ~     http://www.apache.org/licenses/LICENSE-2.0
  ~
  ~ Unless required by applicable law or agreed to in writing, software
  ~ distributed under the License is distributed on an "AS IS" BASIS,
  ~ WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  ~ See the License for the specific language governing permissions and
  ~ limitations under the License.
  --%>

<%@ page import="java.util.HashMap" %>
<%@ page import="org.wso2.carbon.CarbonConstants" %>
<%@ page import="org.apache.axis2.context.ConfigurationContext" %>
<%@ page import="org.wso2.carbon.ui.CarbonUIUtil" %>
<%@ page import="org.wso2.carbon.utils.ServerConstants" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.wso2.carbon.identity.governance.ui.IdentityGovernanceAdminClient" %>
<%@ page import="org.wso2.carbon.identity.governance.stub.bean.ConnectorConfig" %>
<%@ page import="org.wso2.carbon.identity.governance.stub.bean.Property" %>
<%@ page import="org.owasp.encoder.Encode" %>


<%

    String cookie = (String) session.getAttribute(ServerConstants.ADMIN_SERVICE_COOKIE);
    String backendServerURL = CarbonUIUtil.getServerURL(config.getServletContext(), session);
    ConfigurationContext configContext = (ConfigurationContext) config.getServletContext()
            .getAttribute(CarbonConstants.CONFIGURATION_CONTEXT);

    Map<String, String> configMap = new HashMap<String, String>();

    IdentityGovernanceAdminClient client = new IdentityGovernanceAdminClient(cookie, backendServerURL, configContext);
    ConnectorConfig[] configs = client.getConnectorList();

%>


<script type="text/javascript">
    jQuery(document).ready(function () {

        jQuery('h2.trigger').click(function () {
            if (jQuery(this).next().is(":visible")) {
                this.className = "active trigger";
            } else {
                this.className = "trigger";
            }
            jQuery(this).next().slideToggle("fast");
            return false; //Prevent the browser jump to the link anchor
        });
    });

    $(function () {
        $('#submitBtn').click(function (e) {
            e.preventDefault();
            $('#addTenantConfigurationForm').submit();
        });
    });

    function cancel() {
        location.href = "../admin/login.jsp";
    }

</script>

<script type="text/javascript">
    function setBooleanValueToTextBox(element) {
        document.getElementById(element.value).value = element.checked;
    }
</script>

<fmt:bundle basename="org.wso2.carbon.identity.event.admin.ui.i18n.Resources">
<div id="middle">

<h2>
    Identity Governance
</h2>

<div id="workArea">
<form id="addTenantConfigurationForm" name="addTenantConfigurationForm" action="add_config_ajaxprocessor.jsp"
      method="post">
    <%
    List<String> values = new ArrayList<String>() {{
        add("true");
        add("false");
    }};
%>

    <%for (int j = 0; j < configs.length; j++) {%>
    <h2 id="role_permission_config_head22" class="active trigger">
        <a href="#"><%=Encode.forHtmlAttribute(configs[j].getFriendlyName())%>
        </a>
    </h2>

    <div class="toggle_container sectionSub" style="margin-bottom:10px; display: none;" id="roleConfig2">

        <table class="carbonFormTable">

            <%
            Property[] connectorProperties = configs[j].getProperties();
                for (int k = 0; k < connectorProperties.length; k++) {
                    String value = connectorProperties[k].getValue();%>

                <tr>
                    <td style="width: 500px;">
                        <%=Encode.forHtmlAttribute(connectorProperties[k].getDisplayName())%>
                    </td>
                    <%
                        if (value.equalsIgnoreCase("true") || value.equalsIgnoreCase("false")) {
                            // assume as boolean value. But actually this must be sent from backend.
                            // will fix for next release.
                    %>
                    <td>
                        <input class="sectionCheckbox" type="checkbox"
                               onclick="setBooleanValueToTextBox(this)"
                                <%if (Boolean.parseBoolean(value)) {%> checked="checked" <%}%>
                               value="<%=Encode.forHtmlAttribute(connectorProperties[k].getName())%>"/>
                        <input id="<%=Encode.forHtmlAttribute(connectorProperties[k].getName())%>"
                               name="<%=Encode.forHtmlAttribute(connectorProperties[k].getName())%>"
                               type="hidden" value="<%=Encode.forHtmlAttribute(value)%>"/>
                    </td>
                    <%
                    } else {%>
                    <td colspan="2"><input type="text" name=<%=Encode.forHtmlAttribute(connectorProperties[k].getName())%>
                                           id=<%=Encode.forHtmlAttribute(connectorProperties[k].getName())%>
                                           style="width:400px"
                                           value="<%=Encode.forHtmlAttribute(value)%>"/>
                    </td>
                    <%}%>
                </tr>
            <%}%>
                </table></div>
    <%}
    %>



<tr id="buttonRow">
    <td class="buttonRow">
        <input class="button" type="button" value="Cancel" onclick="cancel()"/>
        <input class="button" type="button" value="Update" id="submitBtn"/>
    </td>
</tr>


</div>
</form>
</div>
</div>
</fmt:bundle>