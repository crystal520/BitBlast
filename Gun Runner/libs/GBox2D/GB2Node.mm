/*
 MIT License
 
 Copyright (c) 2010 Andreas Loew / www.code-and-web.de
 
 For more information about htis module visit
 http://www.PhysicsEditor.de
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "GB2Node.h"
#import "GB2Engine.h"
#import "GB2ShapeCache.h"

@implementation GB2Node

@synthesize ccNode, deleteLater, anchorPoint, visible, contentSize, parent, scale, position, scaleX, scaleY, rotation, shapeString, needsSetActive, newActive;

-(id) initWithShape:(NSString *)shape bodyType:(b2BodyType)bodyType node:(CCNode*)node;
{
    self = [super init];
    
	if( self ) 
    {
        shapeString = [shape retain];
        world = [[GB2Engine sharedInstance] world];
        
        b2BodyDef bodyDef;
        bodyDef.type = bodyType;
        bodyDef.position.Set(0,0);
        bodyDef.angle = 0;
        body = world->CreateBody(&bodyDef);
        
        // set user data and retain self
        body->SetUserData([self retain]);
        
        // set the node
        self.ccNode = node;
        
        // set shape
        if(shape)
        {
            [self setBodyShape:shape];            
        }
    }
    
    return self;    
}

- (void) dealloc {
    [shapeString release];
    [super dealloc];
}

-(void) addEdgeFrom:(b2Vec2)start to:(b2Vec2)end
{
    b2EdgeShape edgeShape;
    edgeShape.Set(start, end);
    body->CreateFixture(&edgeShape,0);
}

-(id) init
{
    if((self = [super init])) {
        
    }
    return self;
}

-(id) initWithNode:(CCNode*)node;
{
    return [self initWithShape:0 bodyType:b2_dynamicBody node:node];
}

-(id) initWithDynamicBody:(NSString *)shape node:(CCNode*)node;
{
    return [self initWithShape:shape bodyType:b2_dynamicBody node:node];
}

-(id) initWithStaticBody:(NSString *)shape node:(CCNode*)node;
{
    return [self initWithShape:shape bodyType:b2_staticBody node:node];
}

-(id) initWithKinematicBody:(NSString *)shape node:(CCNode*)node;
{
    return [self initWithShape:shape bodyType:b2_kinematicBody node:node];
}

-(void*) shapeCacheFixtureUserdataForValue:(int)value
{
    return 0;
}

-(void) destroyBody
{
    if(body)
    {
        // destroy the body and release the instance count
        // which was part of the body userdata
        world->DestroyBody(body);
        body=0;
        
        // release self - 
        [self release];
    }
}

-(void) deleteNow
{    
    // remove object from cocos2d parent node
    [ccNode removeFromParentAndCleanup:YES];
    self.ccNode = nil;

    // delete the body
    [self destroyBody];
}

-(CCAction*) runAction: (CCAction*) action
{
    return [ccNode runAction:action];
}

-(void) stopAllActions
{
    [ccNode stopAllActions];    
}

-(void) stopAction: (CCAction*) action
{
    [ccNode stopAction:action];
}

- (void) stopActionByTag:(int)tag {
    [ccNode stopActionByTag:tag];
}

- (void) pauseSchedulerAndActions {
    [ccNode pauseSchedulerAndActions];
}

- (void) resumeSchedulerAndActions {
    [ccNode resumeSchedulerAndActions];
}

-(void) setParent:(CCNode*)newParent
{
    [newParent addChild:ccNode];
}

-(void) setParent:(CCNode*)newParent z:(float)z
{
    [newParent addChild:ccNode z:z];    
}

-(float) widthInM
{
    return [ccNode contentSize].width / PTM_RATIO;
}

-(void) setLinearDamping:(float)linearDamping
{
    body->SetLinearDamping(linearDamping);    
}

-(void) setAngularDamping:(float)angularDamping
{
    body->SetAngularDamping(angularDamping);    
}

-(void) setBodyShape:(NSString*)shape
{
    b2Fixture *f;
    while((f = body->GetFixtureList()))
    {
        body->DestroyFixture(f);        
    }
    
    if(shape)
    {
        GB2ShapeCache *shapeCache = [GB2ShapeCache sharedShapeCache];
        [shapeCache addFixturesToBody:body forShapeName:shape];
        ccNode.anchorPoint = [shapeCache anchorPointForShape:shape];        
    }
}

-(void) setScale:(float)newScale
{
    // currently only graphics
    ccNode.scale = newScale;
}


-(b2Fixture*) addFixture:(b2FixtureDef*)fixtureDef
{
    return body->CreateFixture(fixtureDef);
}

-(void) setBody:(NSString*)shapeName type:(b2BodyType)bodyType position:(b2Vec2)pos
{
    assert(body);
    [self setBodyShape:shapeName];
    [self setBodyType:bodyType];
    [self setPhysicsPosition:pos];
}

-(void) clrCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId  || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits &= ~bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    }  
}

-(void) addCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits |= bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    } 
}

-(void) setCollisionMaskBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.maskBits = bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();            
    } 
}

-(void) setCollisionMaskBits:(uint16)bits
{
    [self setCollisionMaskBits:bits forId:nil];
}

-(void) clrCollisionMaskBits:(uint16)bits
{
    [self clrCollisionMaskBits:bits forId:nil];
}

-(void) addCollisionMaskBits:(uint16)bits
{
    [self addCollisionMaskBits:bits forId:nil];
}

-(void) addCollisionCategoryBits:(uint16)bits
{
    [self addCollisionCategoryBits:bits forId:nil];
}

-(void) clrCollisionCategoryBits:(uint16)bits
{
    [self clrCollisionCategoryBits:bits forId:nil];
}

-(void) setCollisionCategoryBits:(uint16)bits
{
    [self setCollisionCategoryBits:bits forId:nil];
}

-(void) addCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits |= bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}

-(void) clrCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits &= ~bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}

-(void) setCollisionCategoryBits:(uint16)bits forId:(NSString*)fixtureId
{
    b2Fixture *f = body->GetFixtureList();
    while(f)
    {
        if(!fixtureId || ([fixtureId isEqualToString:(NSString*)f->GetUserData()]))
        {
            b2Filter filter = f->GetFilterData();
            filter.categoryBits = bits;        
            f->SetFilterData(filter);
        }
        f = f->GetNext();
    }        
}


-(void) setKinematicBody:(NSString*)shapeName position:(b2Vec2)pos
{
    [self setBody:shapeName type:b2_kinematicBody position:pos];
}

-(void) setDynamicBody:(NSString*)shapeName position:(b2Vec2)pos
{
    [self setBody:shapeName type:b2_dynamicBody position:pos];
}

-(void) setStaticBody:(NSString*)shapeName position:(b2Vec2)pos
{
    [self setBody:shapeName type:b2_staticBody position:pos];    
}


-(void)updateCCFromPhysics
{
    b2Vec2 bodyPosition = body->GetPosition();
    ccNode.position = CGPointMake(PTM_RATIO*bodyPosition.x, PTM_RATIO*bodyPosition.y);
    ccNode.rotation = -1 * CC_RADIANS_TO_DEGREES(body->GetAngle());
}

- (void) updatePhysicsFromCC {
    CGPoint screenPos = [[CCDirector sharedDirector] convertToUI:[ccNode convertToWorldSpace:CGPointMake(ccNode.contentSize.width * ccNode.anchorPoint.x, ccNode.contentSize.height * ccNode.anchorPoint.y)]];
    screenPos = CGPointMake(screenPos.x / PTM_RATIO / [ResolutionManager sharedSingleton].imageScale, ([CCDirector sharedDirector].winSize.height - screenPos.y) / PTM_RATIO / [ResolutionManager sharedSingleton].imageScale);
    b2Vec2 nodePosition = b2Vec2(screenPos.x, screenPos.y);
    float32 angle = CC_DEGREES_TO_RADIANS(-ccNode.rotation);
    body->SetTransform(nodePosition, angle);
}

-(void) setFixedRotation:(bool)fixedRotation
{
    assert(body);
    body->SetFixedRotation(fixedRotation);
}

-(void) setLinearVelocity:(b2Vec2)velocity
{
    assert(body);
    body->SetLinearVelocity(velocity);
}

-(void) applyLinearImpulse:(b2Vec2)impulse point:(b2Vec2)point 
{
    assert(body);
    body->ApplyLinearImpulse(impulse, point);
}

-(b2Vec2) physicsPosition
{
    assert(body);
    return body->GetPosition();
}

-(b2Vec2) worldCenter
{
    assert(body);
    return body->GetWorldCenter();
}
-(float) mass
{
    assert(body);
    return body->GetMass();
}

-(void) setBodyType:(b2BodyType)bodyType;
{
    assert(body);
    body->SetType(bodyType);
}

-(BOOL) isAwake
{
    return body->IsAwake();
}

-(void) applyForce:(b2Vec2)force point:(b2Vec2)point
{
    assert(body);
    body->ApplyForce(force, point);
}

-(float) angle
{
    assert(body);
    return body->GetAngle();
}

-(void) setTransform:(b2Vec2)pos angle:(float)angle
{
    assert(body);
    body->SetTransform(pos, angle);
}

-(void) setAngle:(float)angle
{
    body->SetTransform(body->GetWorldCenter(), angle);
}

-(void) setPhysicsPosition:(b2Vec2)pos
{
    assert(body);
    ccNode.position = CGPointFromb2Vec2(pos);
    body->SetTransform(pos, body->GetAngle());
}

-(void)setCcPosition:(CGPoint)pos
{
    assert(body);
    ccNode.position = pos;
    body->SetTransform(b2Vec2FromCGPoint(pos), body->GetAngle());
}

-(CGPoint)ccPosition
{
    return ccNode.position;
}

-(bool) active
{
    return body->IsActive();
}

-(void) setActive:(bool)isActive
{
    if(world->IsLocked()) {
        needsSetActive = true;
        newActive = isActive;
    }
    else {
        body->SetActive(isActive);
        [self setAwake:isActive];
    }
}

-(bool) awake
{
    return body->IsAwake();
}

- (void) setAwake:(BOOL)isAwake {
    body->SetAwake(isAwake);
}

-(b2Vec2) linearVelocity
{
    return body->GetLinearVelocity();
}

-(void*)shapeCacheFixtureUserdataForValue
{
    return 0;
}

-(void) setBullet:(bool)bulletFlag
{
    body->SetBullet(bulletFlag);
}

-(b2Fixture*) createFixture:(const b2FixtureDef*)fixtureDef
{
    return body->CreateFixture(fixtureDef);
}

-(int) objectTag
{
    return objectTag;
}

-(void) setObjectTag:(int)aTag
{
    objectTag = aTag;
}

-(void) setAngularVelocity:(float32)v
{
    body->SetAngularVelocity(v);
}

-(void)setVisible:(BOOL)isVisible
{
    ccNode.visible = isVisible;
}

- (BOOL) getVisible {
    return ccNode.visible;
}

- (void) setAnchorPoint:(CGPoint)newAnchorPoint {
    ccNode.anchorPoint = newAnchorPoint;
}

- (CGPoint) getAnchorPoint {
    return ccNode.anchorPoint;
}

- (void) addChild:(CCNode *)node {
    [ccNode addChild:node];
}

- (void) setContentSize:(CGSize)newContentSize {
    ccNode.contentSize = newContentSize;
}

- (CGSize) getContentSize {
    return ccNode.contentSize;
}

- (CCNode*) getParent {
    return ccNode.parent;
}

- (void) setPosition:(CGPoint)newPosition {
    ccNode.position = newPosition;
}

- (CGPoint) getPosition {
    return ccNode.position;
}

- (void) setRotation:(float)newRotation {
    ccNode.rotation = newRotation;
}

- (float) getRotation {
    return ccNode.rotation;
}

- (CGPoint)convertToWorldSpace:(CGPoint)nodePoint {
    return [ccNode convertToWorldSpace:nodePoint];
}

- (void) setScaleX:(float)newScaleX {
    ccNode.scaleX = newScaleX;
}

- (float) getScaleX {
    return ccNode.scaleX;
}

- (void) setScaleY:(float)newScaleY {
    ccNode.scaleY = newScaleY;
}

- (float) getScaleY {
    return ccNode.scaleY;
}

@end
