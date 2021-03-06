package org.wso2.carbon.identity.recovery.endpoint.impl;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.wso2.carbon.identity.application.common.model.User;
import org.wso2.carbon.identity.recovery.IdentityRecoveryClientException;
import org.wso2.carbon.identity.recovery.IdentityRecoveryConstants;
import org.wso2.carbon.identity.recovery.IdentityRecoveryException;
import org.wso2.carbon.identity.recovery.bean.ChallengeQuestionsResponse;
import org.wso2.carbon.identity.recovery.endpoint.Constants;
import org.wso2.carbon.identity.recovery.endpoint.SecurityQuestionsApiService;
import org.wso2.carbon.identity.recovery.endpoint.Utils.RecoveryUtil;
import org.wso2.carbon.identity.recovery.endpoint.dto.InitiateAllQuestionResponseDTO;
import org.wso2.carbon.identity.recovery.password.SecurityQuestionPasswordRecoveryManager;

import javax.ws.rs.core.Response;

public class SecurityQuestionsApiServiceImpl extends SecurityQuestionsApiService {

    private static final Log LOG = LogFactory.getLog(SecurityQuestionsApiServiceImpl.class);

    @Override
    public Response securityQuestionsGet(String username, String realm, String tenantDomain) {

        User user = new User();
        user.setUserStoreDomain(realm);
        user.setUserName(username);
        user.setTenantDomain(tenantDomain);

        InitiateAllQuestionResponseDTO initiateAllQuestionResponseDTO = null;

        SecurityQuestionPasswordRecoveryManager securityQuestionBasedPwdRecoveryManager =
                RecoveryUtil.getSecurityQuestionBasedPwdRecoveryManager();
        try {
            ChallengeQuestionsResponse challengeQuestionResponse = securityQuestionBasedPwdRecoveryManager
                    .initiateUserChallengeQuestionAtOnce(user);
            initiateAllQuestionResponseDTO = RecoveryUtil.getInitiateQuestionResponseDTO(challengeQuestionResponse);

        } catch (IdentityRecoveryClientException e) {
            if (LOG.isDebugEnabled()) {
                LOG.debug("Client Error while initiating password recovery flow at once using security questions ", e);
            }
            if (IdentityRecoveryConstants.ErrorMessages.ERROR_CODE_CHALLENGE_QUESTION_NOT_FOUND.getCode()
                    .equals(e.getErrorCode())) {
                return Response.noContent().build();
            }

            RecoveryUtil.handleBadRequest(e.getMessage(), e.getErrorCode());

        } catch (IdentityRecoveryException e) {
            RecoveryUtil.handleInternalServerError(Constants.SERVER_ERROR, e.getErrorCode(), LOG, e);

        } catch (Throwable throwable) {
            RecoveryUtil.handleInternalServerError(Constants.SERVER_ERROR, IdentityRecoveryConstants
                    .ErrorMessages.ERROR_CODE_UNEXPECTED.getCode(), LOG, throwable);
        }
        return Response.ok(initiateAllQuestionResponseDTO).build();
    }
}
