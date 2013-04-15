package models;

import play.db.ebean.Model;

/**
 */
public class Text extends Model
{
    public String name;

    public String getTest()
    {
        return name;
    }
}
