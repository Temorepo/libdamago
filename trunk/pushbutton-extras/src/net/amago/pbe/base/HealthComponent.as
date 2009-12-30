package libdamago.pushbutton.components {
import com.pblabs.components.basic.HealthEvent;
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.util.ClassUtil;

public class HealthComponent extends EntityComponent
{
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(HealthComponent);
    public static var DAMAGED :String = "HealthDamaged";

    public static var DIED :String = "HealthDead";
    public static const EVENT_NAME :String = "healthChanged";
    public static var HEALED :String = "HealthHealed";
    public static var RESURRECTED :String = "HealthResurrected";
    public var damageMagnitude :Number = 1.0;
    public var damageModifier :Array = new Array();
    public var destroyOnDeath :Boolean = true;
    public var maxHealth :Number = 100;
	public var timeRef :PropertyReference;

    public function HealthComponent ()
    {
        super();
    }

    /**
     * How far are we from being fully healthy?
     */
    public function get amountOfDamage () :Number
    {
        return maxHealth - _health;
    }

    public function get health () :Number
    {
        return _health;
    }

//    public function set health (val :Number) :void
//    {
//        setValue(val);
//    }

    public function set health (value :Number) :void
    {
        // Clamp the amount of damage.
        if (value < 0)
            value = 0;
        if (value > maxHealth)
            value = maxHealth;

        // Notify via a HealthEvent.
        var he :HealthEvent;

        if (value < _health) {
            he = new HealthEvent(DAMAGED, value - _health, value, _lastDamageOriginator);
            owner.eventDispatcher.dispatchEvent(he);
        }

        if (_health > 0 && value == 0) {
            he = new HealthEvent(DIED, value - _health, value, _lastDamageOriginator);
            owner.eventDispatcher.dispatchEvent(he);
        }

        if (_health == 0 && value > 0) {
            he = new HealthEvent(RESURRECTED, value - _health, value, _lastDamageOriginator);
            owner.eventDispatcher.dispatchEvent(he);
        }

        if (_health > 0 && value > _health) {
            he = new HealthEvent(HEALED, value - _health, value, _lastDamageOriginator);
            if (owner && owner.eventDispatcher)
                owner.eventDispatcher.dispatchEvent(he);
        }

        // Set new health value.
        //Logger.print(this, "Health becomes " + _Health);
        _health = value;

        // Handle destruction...
        if (destroyOnDeath && _health <= 0) {
            // Kill the owning container if requested.
            owner.destroy();
        }
    }

    public function get isDead () :Boolean
    {
        return _health <= 0;
    }

    /**
     * Time in milliseconds since the last damage this unit received.
     */
    public function get timeSinceLastDamage () :Number
    {
        return time - _timeOfLastDamage;
    }

    /**
     * Apply damage!
     *
     * @param amount Number of HP to debit (positive) or credit (negative).
     * @param damage damageType String identifier for the type of damage. Used
     *                          to lookup and apply a damage modifier from DamageModifier.
     * @param originator The entity causing the damage, if any.
     */
    public function damage (amount :Number, damageType :String = null, originator :IEntity =
        null) :void
    {
        _lastDamageOriginator = originator;

        // Allow modification of damage based on type.
        if (damageType && damageModifier.hasOwnProperty(damageType)) {
            //Logger.print(this, "Damage modified by entry for type '" + damageType + "' factor of " + DamageModifier[damageType]);
            amount *= damageModifier[damageType];
        }

        // For the flash magnitude, average in preceding fade. 
        damageMagnitude = Math.min(1.0, (amount / _health) * 4);
        _timeOfLastDamage = time;

        // Apply the damage.
        health -= amount;

        // If you wanted to do clever things with the last guy to hurt you,
        // you might want to keep this value set. But since it can have GC
        // implications and also lead to stale data we clear it.
        _lastDamageOriginator = null;
    }

    override protected function onAdd () :void
    {
        _health = maxHealth;
        _timeOfLastDamage = -1000;
    }
	
	protected function get time () :Number
	{
		return owner.getProperty(timeRef) as Number;
	}

    private var _health :Number = 100;
    private var _lastDamageOriginator :IEntity = null;
    private var _timeOfLastDamage :Number = 0;
}
}