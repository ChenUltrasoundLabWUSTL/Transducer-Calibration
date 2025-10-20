function PicoStop(hApp)
    invoke(hApp.hPicoScope, 'ps5000aStop');
    disconnect(hApp.hPicoScope);
    delete(hApp.hPicoScope);
end