package sfs3.client.bitswarm.rdp;

interface ReliableInternals {
    function getPacketBufferSize():Int;
    function getFragBufferSize():Int;
    function getBufferDump():Array<String>;
    function getFragBufferDump():Array<String>;
    function getUnAckedDump():Array<String>;
    function getUnAckedIds():Array<Int>;
    function getCurrentRTT():Float;
}
