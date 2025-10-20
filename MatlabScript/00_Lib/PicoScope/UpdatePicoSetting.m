function UpdatePicoSetting(hApp)

    hApp.PicoSetting.samplePre = hApp.EditFieldPre.Value;
    hApp.PicoSetting.samplePost = hApp.EditFieldPost.Value;
    hApp.PicoSetting.freqStartSC = hApp.EditFieldFreqStartSC.Value;
    hApp.PicoSetting.freqEndSC = hApp.EditFieldFreqEndSC.Value;
    hApp.PicoSetting.freqStartIC = hApp.EditFieldFreqStartIC.Value;
    hApp.PicoSetting.freqEndIC = hApp.EditFieldFreqEndIC.Value;
    hApp.PicoSetting.freqSample = hApp.EditFieldFs.Value;

end