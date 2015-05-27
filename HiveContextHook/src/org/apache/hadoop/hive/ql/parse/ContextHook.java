package org.apache.hadoop.hive.ql.parse;

import org.apache.hadoop.hive.ql.hooks.ExecuteWithHookContext;
import org.apache.hadoop.hive.ql.hooks.HookContext;

import org.apache.hadoop.hive.ql.plan.api.Query;
import java.net.HttpURLConnection;
import java.net.URL;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.DataOutputStream;
import java.io.BufferedReader;


import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.net.MalformedURLException;
import org.apache.http.HttpResponse;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.entity.StringEntity;
import org.apache.http.impl.client.DefaultHttpClient;

/**
 * Created by liuxiao on 15/4/13.
 */
public class ContextHook implements ExecuteWithHookContext {
    @Override
    public void run(HookContext hookContext) throws Exception {
        System.out.println("do nothing");
        Query query = hookContext.getQueryPlan().getQuery();
        String jsonPlan = hookContext.getQueryPlan().getJSONQuery(query);
        DefaultHttpClient httpClient = new DefaultHttpClient();
        postToURL("http://10.105.51.252:4567/", jsonPlan,httpClient);
        //System.out.println(response);
    }

    public void postToURL(String url, String message, DefaultHttpClient httpClient) throws IOException,RuntimeException {
        HttpPost postRequest = new HttpPost(url);
        StringEntity input = new StringEntity(message);
        input.setContentType("application/json");
        postRequest.setEntity(input);
        httpClient.execute(postRequest);

        /*if (response.getStatusLine().getStatusCode() != 200) {
            throw new RuntimeException("Failed : HTTP error code : "
                    + response.getStatusLine().getStatusCode());
        }

        BufferedReader br = new BufferedReader(
                new InputStreamReader((response.getEntity().getContent())));

        String output;
        StringBuffer totalOutput = new StringBuffer();
        while ((output = br.readLine()) != null) {
            System.out.println(output);
            totalOutput.append(output);
        }
        return totalOutput.toString();
        */
    }

}
