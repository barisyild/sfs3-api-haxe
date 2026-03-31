package sfs3.client.bitswarm;
import sfs3.client.bitswarm.io.IResponse;

interface IController
{
    public function getId():Int;
    public function handleMessage(resp:IResponse):Void;
}
