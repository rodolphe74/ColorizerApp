//
//  OpenCVHelper.m
//  Colorizer
//
//  Created by Cordenie Rodolphe on 25/06/2025.
//

#import <opencv2/opencv.hpp>
#import <AppKit/AppKit.h>
#import "OpenCVHelper.h"

// the 313 ab cluster centers from pts_in_hull.npy (already transposed)
static float hull_pts[] = { -90., -90., -90., -90., -90., -80., -80., -80., -80., -80., -80., -80., -80., -70., -70.,
    -70., -70., -70., -70., -70., -70., -70., -70., -60., -60., -60., -60., -60., -60., -60., -60., -60., -60., -60.,
    -60., -50., -50., -50., -50., -50., -50., -50., -50., -50., -50., -50., -50., -50., -50., -40., -40., -40., -40.,
    -40., -40., -40., -40., -40., -40., -40., -40., -40., -40., -40., -30., -30., -30., -30., -30., -30., -30., -30.,
    -30., -30., -30., -30., -30., -30., -30., -30., -20., -20., -20., -20., -20., -20., -20., -20., -20., -20., -20.,
    -20., -20., -20., -20., -20., -10., -10., -10., -10., -10., -10., -10., -10., -10., -10., -10., -10., -10., -10.,
    -10., -10., -10., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 0., 10., 10., 10., 10., 10.,
    10., 10., 10., 10., 10., 10., 10., 10., 10., 10., 10., 10., 10., 20., 20., 20., 20., 20., 20., 20., 20., 20., 20.,
    20., 20., 20., 20., 20., 20., 20., 20., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30., 30.,
    30., 30., 30., 30., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40., 40.,
    40., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 50., 60., 60., 60.,
    60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 60., 70., 70., 70., 70., 70., 70.,
    70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 70., 80., 80., 80., 80., 80., 80., 80., 80., 80.,
    80., 80., 80., 80., 80., 80., 80., 80., 80., 80., 90., 90., 90., 90., 90., 90., 90., 90., 90., 90., 90., 90., 90.,
    90., 90., 90., 90., 90., 90., 100., 100., 100., 100., 100., 100., 100., 100., 100., 100., 50., 60., 70., 80., 90.,
    20., 30., 40., 50., 60., 70., 80., 90., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., -20., -10., 0., 10., 20.,
    30., 40., 50., 60., 70., 80., 90., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., 100., -40.,
    -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., 100., -50., -40., -30., -20., -10., 0., 10., 20.,
    30., 40., 50., 60., 70., 80., 90., 100., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80.,
    90., 100., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., 100., -70., -60.,
    -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., 100., -80., -70., -60., -50., -40.,
    -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., 80., 90., -80., -70., -60., -50., -40., -30., -20., -10.,
    0., 10., 20., 30., 40., 50., 60., 70., 80., 90., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20.,
    30., 40., 50., 60., 70., 80., 90., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30.,
    40., 50., 60., 70., 80., 90., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40.,
    50., 60., 70., 80., -110., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50.,
    60., 70., 80., -110., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60.,
    70., 80., -110., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70.,
    -110., -100., -90., -80., -70., -60., -50., -40., -30., -20., -10., 0., 10., 20., 30., 40., 50., 60., 70., -90.,
    -80., -70., -60., -50., -40., -30., -20., -10., 0. };


@implementation OpenCVHelper

- (int) colorizeWithBwMat:(const cv::Mat &)img protoFile:(const char *)protoFilePath weightsFile:(const char *)weightsFilePath matrice:(cv::Mat *_Nonnull) matOut {

    double t = (double)cv::getTickCount();
    
    // fixed input size for the pretrained network
    const int W_in = 224;
    const int H_in = 224;
    
    cv::dnn::Net net;
    try {
        net = cv::dnn::readNetFromCaffe(protoFilePath, weightsFilePath);
    } catch (cv::Exception& e) {
        return 1;
    }
    
    // setup additional layers:
    int sz[] = { 2, 313, 1, 1 };
    const cv::Mat pts_in_hull(4, sz, CV_32F, hull_pts);
    
    cv::Ptr<cv::dnn::Layer> class8_ab = net.getLayer("class8_ab");
    class8_ab->blobs.push_back(pts_in_hull);
    cv::Ptr<cv::dnn::Layer> conv8_313_rh = net.getLayer("conv8_313_rh");
    conv8_313_rh->blobs.push_back(cv::Mat(1, 313, CV_32F, cv::Scalar(2.606)));
    
    // extract L channel and subtract mean
    cv::Mat lab, L, input;
    img.convertTo(img, CV_32F, 1.0 / 255);
    cvtColor(img, lab, cv::COLOR_BGR2Lab);
    extractChannel(lab, L, 0);
    resize(L, input, cv::Size(W_in, H_in));
    input -= 50;
    
    // run the L channel through the network
    cv::Mat inputBlob = cv::dnn::blobFromImage(input);
    net.setInput(inputBlob);
    cv::Mat result = net.forward();
    
    // retrieve the calculated a,b channels from the network output
    cv::Size siz(result.size[2], result.size[3]);
    cv::Mat a = cv::Mat(siz, CV_32F, result.ptr(0, 0));
    cv::Mat b = cv::Mat(siz, CV_32F, result.ptr(0, 1));
    resize(a, a, img.size());
    resize(b, b, img.size());
    
    // merge, and convert back to BGR
    cv::Mat color, chn[] = { L, a, b };
    merge(chn, 3, lab);
    cvtColor(lab, color, cv::COLOR_Lab2BGR);
    
    t = ((double)cv::getTickCount() - t) / cv::getTickFrequency();
    std::cout << "Time taken : " << t << " secs" << std::endl;
    
    color *= 255;
    cv::imwrite("resultat.jpg", color);
    *matOut = color;

    return 0;
}



- (cv::Mat) fusionVerticalSplitWithMatColor:(const cv::Mat&)matColor andMatGray:(const cv::Mat&)matGray at:(int) splitX
{
    
    // Vérifier la validité
    if (matColor.empty() || matGray.empty())
        throw std::runtime_error("Images invalides");

    if (matColor.size() != matGray.size())
        throw std::runtime_error("Les tailles ne correspondent pas");

    if (matColor.channels() != 3 || matGray.channels() != 1)
        throw std::runtime_error("Format attendu : couleur en BGR, niveau de gris en 1 canal");

    if (splitX < 0 || splitX > matColor.cols)
        throw std::out_of_range("splitX doit être compris entre 0 et la largeur de l’image");
    
    cv::Mat bw_bgr;
    if (matGray.channels() == 1) {
        cv::cvtColor(matGray, bw_bgr, cv::COLOR_GRAY2BGR);
    } else {
        bw_bgr = matGray.clone(); // au cas où bw est déjà en 3 canaux
    }

    // Convertir le niveau de gris en couleur
    cv::Mat matGrayColor;
    cv::cvtColor(matGray, matGrayColor, cv::COLOR_GRAY2BGR);

    // Créer l'image fusionnée (initialement vide)
    cv::Mat fusion(matColor.rows * 2, matColor.cols, CV_8UC3);

    // Remplir la moitié supérieure : matColor à gauche jusqu’à splitX, ensuite matGrayColor
    for (int y = 0; y < matColor.rows; ++y) {
        // Ligne dans l’image finale (haut)
        cv::Vec3b* dstTop = fusion.ptr<cv::Vec3b>(y);
        const cv::Vec3b* colTop = matColor.ptr<cv::Vec3b>(y);
        const cv::Vec3b* grayTop = matGrayColor.ptr<cv::Vec3b>(y);

        for (int x = 0; x < matColor.cols; ++x) {
            dstTop[x] = (x < splitX) ? colTop[x] : grayTop[x];
        }
    }

    // Remplir la moitié inférieure : inverse (gray à gauche, color à droite)
    for (int y = 0; y < matColor.rows; ++y) {
        // Ligne dans l’image finale (bas)
        cv::Vec3b* dstBot = fusion.ptr<cv::Vec3b>(y + matColor.rows);
        const cv::Vec3b* colBot = matColor.ptr<cv::Vec3b>(y);
        const cv::Vec3b* grayBot = matGrayColor.ptr<cv::Vec3b>(y);

        for (int x = 0; x < matColor.cols; ++x) {
            dstBot[x] = (x < splitX) ? grayBot[x] : colBot[x];
        }
    }
    
    return fusion;
}
@end
