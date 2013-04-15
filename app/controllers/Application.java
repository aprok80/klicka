package controllers;

import models.Text;
import play.*;
import play.api.mvc.Request;
import play.data.Form;
import play.mvc.*;

import views.html.*;

import java.util.ArrayList;
import java.util.Map;

import static play.libs.Json.toJson;

public class Application extends Controller {

    public static ArrayList<String> test = new ArrayList<>();

    public static Result index() {
        return ok(index.render("Hallo World."));
    }

    public static Result addText()
    {
        Http.Request request = request();
        Http.RequestBody body = request.body();
        Map<String,String[]> stringMap = body.asFormUrlEncoded();
        Logger.info( stringMap.get("name")[0] );
        test.add(stringMap.get("name")[0]);
        return redirect(routes.Application.formTest());
    }

    public static Result formTest()
    {
        return ok(formtest.render( test ));
    }

    public static Result getTexts()
    {
        return ok(toJson(test));
    }
}
