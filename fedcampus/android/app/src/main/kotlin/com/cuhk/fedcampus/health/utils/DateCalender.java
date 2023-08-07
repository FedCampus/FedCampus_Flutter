package com.cuhk.fedcampus.health.utils;

import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.Date;
import java.util.concurrent.TimeUnit;

public class DateCalender {

    public static Calendar now = Calendar.getInstance();

    public static int firstDay = Calendar.MONDAY;

    public static int getDateNumberFromNow(int dayTime) {
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.DATE, dayTime);
        return cal.get(Calendar.YEAR) * 10000 + (cal.get(Calendar.MONTH) + 1) * 100 + cal.get(Calendar.DATE);
    }

    public static int IntervalDay(int start, int end) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        try {
            Date startDate = sdf.parse(String.valueOf(start));
            Date endDate = sdf.parse(String.valueOf(end));
            long diff = endDate.getTime() - startDate.getTime();
            return (int) TimeUnit.DAYS.convert(diff, TimeUnit.MILLISECONDS);
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    public static int add(int start, int day) {
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        try {
            Date startDate = sdf.parse(String.valueOf(start));
            cal.setTime(startDate);
            cal.add(Calendar.DATE, day);
            return cal.get(Calendar.YEAR) * 10000 + (cal.get(Calendar.MONTH) + 1) * 100 + cal.get(Calendar.DATE);

        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    public static int DateCompare(int date1, int date2) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        try {
            Date dateOne = sdf.parse(String.valueOf(date1));
            Date dateTwo = sdf.parse(String.valueOf(date2));
            assert dateOne != null;
            return dateOne.compareTo(dateTwo);
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }


    public static int[] getCurrentDate() {
        int year = now.get(Calendar.YEAR);
        int month = now.get(Calendar.MONTH) + 1;
        int day = now.get(Calendar.DATE);

        return new int[]{year, month, day};
    }

    public static int getCurrentDateNumber() {
        int year = now.get(Calendar.YEAR);
        int month = now.get(Calendar.MONTH) + 1;
        int day = now.get(Calendar.DATE);

        return year * 10000 + month * 100 + day;
    }

    public static int[] WrappedGetCurrentDateToGetData(int[] date) {

        int dateTime = date[0] * 10000 + date[1] * 100 + date[2];

        return new int[]{dateTime, dateTime};
    }

    // the start date and end date of the week
    public static int[] getWeek() {

        // Get calendar set to current date and time
        Calendar c = Calendar.getInstance();

        c.setFirstDayOfWeek(firstDay);

        // Set the calendar to monday of the current week
        c.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);

        // Print dates of the current week starting on Monday
        DateFormat df = new SimpleDateFormat("yyyyMMdd");
        int start_time = Integer.parseInt(df.format(c.getTime()));
        c.add(Calendar.DATE, 6);
        int end_time = Integer.parseInt(df.format(c.getTime()));

        return new int[]{start_time, end_time};
    }
}
