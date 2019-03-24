package com.example.video_app;

import com.coremedia.iso.boxes.Container;
import com.googlecode.mp4parser.FileDataSourceImpl;
import com.googlecode.mp4parser.authoring.Movie;
import com.googlecode.mp4parser.authoring.Track;
import com.googlecode.mp4parser.authoring.builder.DefaultMp4Builder;
import com.googlecode.mp4parser.authoring.container.mp4.MovieCreator;
import com.googlecode.mp4parser.authoring.tracks.AppendTrack;
import com.googlecode.mp4parser.authoring.tracks.CroppedTrack;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.nio.channels.Channels;
import java.nio.channels.WritableByteChannel;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import io.flutter.plugin.common.MethodChannel;

/**
 * This class contains native methods to be called from flutter.
 * Also this class contains keys for methods and their arguments
 * (we need such keys to get them from flutter message).
 */
class NativeApi {

    static final String CROP_VIDEO_METHOD = "cropVideo";
    static String CROP_VIDEO_METHOD_ARG1 = "partsToSaveAfterCroppingSec";
    static String CROP_VIDEO_METHOD_ARG2 = "clipInputPath";
    static String CROP_VIDEO_METHOD_ARG3 = "clipOutputPath";

    /**
     * Crops video, saves it and sends method result to flutter with cropped video path
     * @param partsToSaveAfterCroppingSec
     * Contains seconds, which are used to clip video.
     * E.g. {1, 5, 6, 8, 15, 26}. From such array we will first cut out
     * video part from 1 to 5. Then we will cut out video part from 6 to 8.
     * Then we will cut out from sec 15 to sec 26. After that we will
     * combine these parts to get a clipped video.
     * @param clipInputPath
     * Path to video we want to clip.
     * @param clipOutputPath
     * Path, where clipped video will be saved.
     * @param result
     * Object we use to send method invocation result back to flutter.
     */
    static void cropVideo(int[] partsToSaveAfterCroppingSec,
                                 String clipInputPath, String clipOutputPath,
                                 MethodChannel.Result result) {
        List<String> tempFilePaths = new ArrayList<>();
        try {
            for (int i = 0; i < partsToSaveAfterCroppingSec.length - 1; i+=2) {
                String tempFileName = clipInputPath.replace(".mp4", "-temp" + (i / 2) + ".mp4");
                trimVideo(clipInputPath, tempFileName,
                        partsToSaveAfterCroppingSec[i], partsToSaveAfterCroppingSec[i + 1]);
                tempFilePaths.add(tempFileName);
            }
            combineVideos(tempFilePaths, clipOutputPath);
            clearUpTempFiles(tempFilePaths);
            result.success(clipOutputPath);
        } catch (IOException e) {
            e.printStackTrace();
            result.error(CROP_VIDEO_METHOD, e.getMessage(), e);
        }
    }

    /**
     * Convenience method for removing unnesessary files.
     * @param tempFilePaths
     * Paths to unnesessary files.
     * @throws IOException
     * If deletion was unsuccessful, we get this.
     */
    private static void clearUpTempFiles(List<String> tempFilePaths) throws IOException {
        for (String path : tempFilePaths) {
            if (!new File(path).getAbsoluteFile().delete()) {
                throw new IOException("Could not delete temp files");
            }
        }
    }

    /**
     * Helper methods for combining clipped video parts.
     * @param videos
     * Videos to combine.
     * @param outputPath
     * Path where we save combined video.
     * @throws IOException
     * If writing was unsuccessful, we get this.
     */
    private static void combineVideos(List<String> videos, String outputPath) throws IOException {
        List<Movie> inMovies = new ArrayList<Movie>();
        for (String videoUri : videos) {
            inMovies.add(MovieCreator.build(videoUri));
        }

        List<Track> videoTracks = new LinkedList<Track>();
        List<Track> audioTracks = new LinkedList<Track>();

        for (Movie m : inMovies) {
            for (Track t : m.getTracks()) {
                if (t.getHandler().equals("soun")) {
                    audioTracks.add(t);
                }
                if (t.getHandler().equals("vide")) {
                    videoTracks.add(t);
                }
            }
        }

        Movie result = new Movie();

        if (!audioTracks.isEmpty()) {
            result.addTrack(new AppendTrack(audioTracks.toArray(new Track[audioTracks.size()])));
        }
        if (!videoTracks.isEmpty()) {
            result.addTrack(new AppendTrack(videoTracks.toArray(new Track[videoTracks.size()])));
        }

        Container out = new DefaultMp4Builder().build(result);

        final FileOutputStream fos = new FileOutputStream(new File(outputPath));
        final WritableByteChannel bb = Channels.newChannel(fos);
        out.writeContainer(bb);
        fos.close();
    }

    /**
     * Helps us to trim video.
     * @param srcFileDir
     * File to trim.
     * @param outFileDir
     * Path to save output to.
     * @param fromSecond
     * Where our trimmed video would start.
     * @param toSecond
     * Where our trimmed video would end.
     * @throws IOException
     * Writing to memory or getting input from memory can
     * cause this exception.
     */
    private static void trimVideo(final String srcFileDir, final String outFileDir,
                                 final double fromSecond, final double toSecond) throws IOException {

        if (fromSecond < 0) {
            return;
        }

        Movie movie = MovieCreator.build(new FileDataSourceImpl(srcFileDir));
        List<Track> tracks = movie.getTracks();
        movie.setTracks(new LinkedList<Track>());
        double startTime = 0, endTime = 0;
        boolean timeCorrected = false;

        for (Track track : tracks) {
            if (track.getSyncSamples() != null && track.getSyncSamples().length > 0) {
                if (timeCorrected) {
                    throw new RuntimeException("The startTime has already been corrected by another track with SyncSample. Not Supported.");
                }
                startTime = correctTimeToNextSyncSample(track, fromSecond);
                endTime = correctTimeToNextSyncSample(track, toSecond);
                timeCorrected = true;
            }
        }

        for (Track track : tracks) {
            long currentSample = 0;
            double currentTime = 0;
            long startSample = -1;
            long endSample = -1;
            for (int i = 0; i < track.getSampleDurations().length; i++) {
                long delta = track.getSampleDurations()[i];

                for (int j = 0; j < 1; j++) {
                    // entry.getDelta() is the amount of time the current sample covers.

                    if (currentTime <= startTime) {
                        // current sample is still before the new starttime
                        startSample = currentSample;
                    }
                    if (currentTime <= endTime) {
                        // current sample is after the new start time and still before the new endtime
                        endSample = currentSample;
                    } else {
                        // current sample is after the end of the cropped video
                        if (endSample == -1) {
                            endSample = currentSample;
                        }
                        break;
                    }
                    currentTime += (double) delta / (double) track.getTrackMetaData().getTimescale();
                    currentSample++;
                }
            }
            movie.addTrack(new CroppedTrack(track, startSample, endSample));
        }
        Container container = new DefaultMp4Builder().build(movie);
        final FileOutputStream fos = new FileOutputStream(new File(String.format(outFileDir)));
        final WritableByteChannel bb = Channels.newChannel(fos);
        container.writeContainer(bb);
        fos.close();
    }

    /**
     * Videos are composed of "samples", which are shown one by one,
     * sample durations are different and we cannot cut video where we want, we can cut video
     * only at the end of a sample. If we cut in the middle of a sample, it can even make mp4 corrupt.
     * To cut our files correctly, we need to correct our cut time a little bit, so that we cannot
     * make file corrupt or get incorrect clipping results.
     * @param track
     * Track, which samples we are going to use to correct our time.
     * @param cutHere
     * Time where we want to cut our video. This time will be corrected.
     * @return
     * Returns corrected value, which we can use to cut our video properly.
     */
    private static double correctTimeToNextSyncSample(Track track, double cutHere) {
        double[] timeOfSyncSamples = new double[track.getSyncSamples().length];
        long currentSample = 0;
        double currentTime = 0;
        for (long dur : track.getSampleDurations()) {
            for (int j = 0; j < 1; j++) {
                if (Arrays.binarySearch(track.getSyncSamples(), currentSample + 1) >= 0) {
                    timeOfSyncSamples[Arrays.binarySearch(track.getSyncSamples(), currentSample + 1)] = currentTime;
                }
                currentTime += (double) dur / (double) track.getTrackMetaData().getTimescale();
                currentSample++;
            }
        }
        for (double timeOfSyncSample : timeOfSyncSamples) {
            if (timeOfSyncSample > cutHere) {
                return timeOfSyncSample;
            }
        }
        return timeOfSyncSamples[timeOfSyncSamples.length - 1];
    }
}
