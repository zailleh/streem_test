# Streem.com.au code test

### Secrets
#### Elasticsearch Credentials
Elastic Search credentials are read from environment variables.

You can add these to your bash/zshrc profile with the following command, replacing the placeholders with the actual username/password.


If you use ZSH
``` sh
echo "\nexport STREEM_ES_TEST_U=$USERNAME" >> ~/.zshrc
echo "\nexport STREEM_ES_TEST_P=$PASSWORD" >> ~/.zshrc
echo "\nexport STREEM_ES_TEST_HOST=$HOSTNAME" >> ~/.zshrc
```

If you use BASH
``` sh
echo "\nexport STREEM_ES_TEST_U=$USERNAME" >> ~/.bash_profile
echo "\nexport STREEM_ES_TEST_P=$PASSWORD" >> ~/.bash_profile
echo "\nexport STREEM_ES_TEST_HOST=$HOSTNAME" >> ~/.bash_profile

```

Similarly, if you were deploying to Heroku, after setting environment variables locally you could use:
``` sh
heroku config:set STREEM_ES_TEST_U=$STREEM_ES_TEST_U
heroku config:set STREEM_ES_TEST_P=$STREEM_ES_TEST_P
heroku config:set STREEM_ES_TEST_HOST=$STREEM_ES_TEST_HOST
```