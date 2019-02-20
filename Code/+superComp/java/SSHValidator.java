package edu.byu.me.sshvalidator;

import ch.ethz.ssh2.InteractiveCallback;

public class SSHValidator implements InteractiveCallback {

    private String passWord;
    private String validationCode;

    public SSHValidator(String passWord, String validationCode) {
        this.passWord = passWord;
        this.validationCode = validationCode;
    }

    @Override
    public String[] replyToChallenge(String name,
                                     String instruction,
                                     int numPrompts,
                                     String[] prompts,
                                     boolean[] echo) throws Exception {
        String[] responses = new String[numPrompts];
        for (int i = 0; i < prompts.length; i++) {
            String prompt = prompts[i];
            System.out.println(prompt);

            switch (prompt) {
                case "Password: ":
                    responses[i] = passWord;
                    System.out.println("Submitted password");
                    break;
                case "Verification code: ":
                    responses[i] = validationCode;
                    System.out.println("Submitted Validation code");
                    break;
                default:
                    throw new IllegalArgumentException();
            }
        }

        return responses;
    }
}
